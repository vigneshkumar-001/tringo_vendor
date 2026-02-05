package com.example.tringo_vendor_new

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.DrawableCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import coil.load
import kotlinx.coroutines.*
import kotlin.math.abs
import kotlin.math.max

class TringoOverlayService : Service() {

    private val TAG = "TRINGO_OVERLAY"

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    private val serviceJob = SupervisorJob()
    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)

    private val PREF = "tringo_call_state"
    private val KEY_USER_CLOSED = "user_closed_during_call"
    private val KEY_LAST_NUMBER = "last_number"

    private var adsAdapter: OverlayAdsAdapter? = null

    private var pendingPhone: String = ""
    private var pendingContact: String = ""

    private var launchedByReceiver = false
    private var postCallPopupMode = false
    private var showOnlyAfterEnd = false

    private var telephonyManager: TelephonyManager? = null
    private var telephonyCallback: TelephonyCallback? = null

    @Suppress("DEPRECATION")
    private var phoneStateListener: android.telephony.PhoneStateListener? = null

    private var isWatchingCallEnd = false
    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE

    private var endConfirmJob: Job? = null
    private var lastNonIdleAt: Long = 0L

    private var incomingAutoHideJob: Job? = null

    private var lastOverlayShownAt: Long = 0L
    private val OVERLAY_DEBOUNCE_MS = 900L

    private var postCallShownOnce = false

    private val INCOMING_SHOW_MS = 10_000L
    private val POST_CALL_SHOW_MS = 15_000L

    // CACHE
    private val CACHE_VALID_MS = 90_000L
    private var cachePhone: String? = null
    private var cacheAt: Long = 0L

    private var cacheIsShop: Boolean = false
    private var cacheTitle: String = ""
    private var cacheSubtitleLine: String = ""
    private var cacheImageUrl: String = ""

    private var cacheAdsTitle: String = "Advertisements"
    private var cacheAdsCards: List<OverlayAdCard> = emptyList()

    private fun isCacheValidFor(phone: String): Boolean {
        val ok = cachePhone == phone && (System.currentTimeMillis() - cacheAt) <= CACHE_VALID_MS
        Log.d(TAG, "isCacheValidFor($phone) => $ok")
        return ok
    }

    private fun saveCache(
        phone: String,
        isShop: Boolean,
        title: String,
        subtitleLine: String,
        imageUrl: String,
        adsTitle: String,
        adsCards: List<OverlayAdCard>
    ) {
        cachePhone = phone
        cacheAt = System.currentTimeMillis()
        cacheIsShop = isShop
        cacheTitle = title
        cacheSubtitleLine = subtitleLine
        cacheImageUrl = imageUrl
        cacheAdsTitle = adsTitle
        cacheAdsCards = adsCards
        Log.d(TAG, "CACHE SAVED phone=$phone isShop=$isShop ads=${adsCards.size}")
    }

    companion object {
        @Volatile var isRunning: Boolean = false

        fun start(
            ctx: Context,
            phone: String,
            contactName: String = "",
            showOnCallEnd: Boolean = false,
            launchedByReceiver: Boolean = false
        ): Boolean {
            val i = Intent(ctx, TringoOverlayService::class.java).apply {
                putExtra("phone", phone)
                putExtra("contactName", contactName)
                putExtra("showOnCallEnd", showOnCallEnd)
                putExtra("launchedByReceiver", launchedByReceiver)
            }

            return try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    try { ctx.startForegroundService(i) }
                    catch (t: Throwable) {
                        Log.e("TRINGO_OVERLAY", "startForegroundService blocked => fallback: ${t.message}")
                        ctx.startService(i)
                    }
                } else {
                    ctx.startService(i)
                }
                true
            } catch (e: Throwable) {
                Log.e("TRINGO_OVERLAY", "start() failed: ${e.message}", e)
                false
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        pendingPhone = intent?.getStringExtra("phone") ?: ""
        pendingContact = intent?.getStringExtra("contactName") ?: ""
        launchedByReceiver = intent?.getBooleanExtra("launchedByReceiver", false) ?: false
        showOnlyAfterEnd = intent?.getBooleanExtra("showOnCallEnd", false) ?: false

        Log.d(TAG, "onStartCommand phone=$pendingPhone showOnlyAfterEnd=$showOnlyAfterEnd launchedByReceiver=$launchedByReceiver")

        val prefs = getSharedPreferences(PREF, MODE_PRIVATE)
        if (pendingPhone.isBlank() || pendingPhone.equals("UNKNOWN", true)) {
            val last = prefs.getString(KEY_LAST_NUMBER, "") ?: ""
            if (last.isNotBlank() && !last.equals("UNKNOWN", true)) {
                pendingPhone = last
            } else {
                stopSelf()
                return START_NOT_STICKY
            }
        }

        prefs.edit().putString(KEY_LAST_NUMBER, pendingPhone).apply()

        startForegroundDataSyncSafe()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            showCallerHeadsUp("Tringo Caller ID", "Enable overlay permission to show popup", "overlay_permission_missing")
            openAppSettings()
            stopSelf()
            return START_NOT_STICKY
        }

        postCallShownOnce = false

        if (!showOnlyAfterEnd) {
            safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
            scheduleIncomingAutoHide()
        }

        startWatchingForCallEnd()
        return START_STICKY
    }

    private fun startForegroundDataSyncSafe() {
        val channelId = "tringo_overlay_service"
        try {
            val nm = getSystemService(NotificationManager::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                nm.createNotificationChannel(
                    NotificationChannel(channelId, "Tringo Overlay", NotificationManager.IMPORTANCE_LOW)
                )
            }

            val notif = NotificationCompat.Builder(this, channelId)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Tringo Caller ID")
                .setContentText("Running...")
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceCompat.startForeground(this, 101, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            } else {
                startForeground(101, notif)
            }
        } catch (t: Throwable) {
            Log.e(TAG, "startForegroundDataSyncSafe failed: ${t.message}", t)
        }
    }

    private fun markUserClosedDuringCall(phone: String) {
        try {
            getSharedPreferences(PREF, MODE_PRIVATE).edit()
                .putBoolean(KEY_USER_CLOSED, true)
                .putString(KEY_LAST_NUMBER, phone)
                .apply()
        } catch (e: Exception) {
            Log.e(TAG, "markUserClosedDuringCall failed: ${e.message}", e)
        }
    }

    private fun clearUserClosedFlag() {
        try {
            getSharedPreferences(PREF, MODE_PRIVATE).edit()
                .putBoolean(KEY_USER_CLOSED, false)
                .apply()
        } catch (_: Exception) {}
    }

    private fun hasReadPhoneState(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) ==
                PackageManager.PERMISSION_GRANTED
    }

    private fun safeCallState(): Int {
        return try {
            telephonyManager?.callState ?: TelephonyManager.CALL_STATE_IDLE
        } catch (_: Throwable) {
            TelephonyManager.CALL_STATE_IDLE
        }
    }

    private fun startWatchingForCallEnd() {
        if (isWatchingCallEnd) return
        if (!hasReadPhoneState()) {
            Log.e(TAG, "READ_PHONE_STATE not granted -> cannot detect call end.")
            return
        }

        isWatchingCallEnd = true
        endConfirmJob?.cancel()

        lastNonIdleAt = System.currentTimeMillis()
        lastState = safeCallState()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cb = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                override fun onCallStateChanged(state: Int) {
                    handleCallState(state)
                }
            }
            telephonyCallback = cb
            try {
                telephonyManager?.registerTelephonyCallback(mainExecutor, cb)
            } catch (_: Exception) {
                startWatchingForCallEndLegacy()
            }
        } else {
            startWatchingForCallEndLegacy()
        }
    }

    @Suppress("DEPRECATION")
    private fun startWatchingForCallEndLegacy() {
        if (!hasReadPhoneState()) return
        val listener = object : android.telephony.PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                handleCallState(state)
            }
        }
        phoneStateListener = listener
        telephonyManager?.listen(listener, android.telephony.PhoneStateListener.LISTEN_CALL_STATE)
    }

    private fun stopWatchingForCallEnd() {
        if (!isWatchingCallEnd) return
        isWatchingCallEnd = false

        endConfirmJob?.cancel()
        endConfirmJob = null

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                telephonyCallback?.let { telephonyManager?.unregisterTelephonyCallback(it) }
                telephonyCallback = null
            } else {
                @Suppress("DEPRECATION")
                phoneStateListener?.let {
                    telephonyManager?.listen(it, android.telephony.PhoneStateListener.LISTEN_NONE)
                }
                phoneStateListener = null
            }
        } catch (_: Exception) {}
    }

    private fun handleCallState(state: Int) {
        val now = System.currentTimeMillis()

        if (state == TelephonyManager.CALL_STATE_RINGING) {
            lastNonIdleAt = now
            if (!showOnlyAfterEnd) {
                if (overlayView == null) safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
                scheduleIncomingAutoHide()
            }
        }

        if (state == TelephonyManager.CALL_STATE_OFFHOOK) {
            lastNonIdleAt = now
            incomingAutoHideJob?.cancel()
            incomingAutoHideJob = null
        }

        if (state != TelephonyManager.CALL_STATE_IDLE) {
            endConfirmJob?.cancel()
            lastState = state
            return
        }

        endConfirmJob?.cancel()
        endConfirmJob = serviceScope.launch {
            delay(1200)
            if (safeCallState() != TelephonyManager.CALL_STATE_IDLE) return@launch
            val idleFor = System.currentTimeMillis() - lastNonIdleAt
            if (idleFor < 900) return@launch
            onCallEndedConfirmed()
        }

        lastState = state
    }

    private fun scheduleIncomingAutoHide() {
        incomingAutoHideJob?.cancel()
        incomingAutoHideJob = serviceScope.launch {
            delay(INCOMING_SHOW_MS)
            if (!postCallPopupMode) removeOverlay()
        }
    }

    private fun onCallEndedConfirmed() {
        if (postCallShownOnce) return
        postCallShownOnce = true

        serviceScope.launch {
            stopWatchingForCallEnd()

            postCallPopupMode = true
            safeShowOverlay(pendingPhone, pendingContact, preferCache = true)

            delay(POST_CALL_SHOW_MS)
            removeOverlay()

            postCallPopupMode = false
            clearUserClosedFlag()
            stopSelf()
        }
    }

    private fun safeShowOverlay(phone: String, contactName: String, preferCache: Boolean) {
        val now = System.currentTimeMillis()
        if (now - lastOverlayShownAt < OVERLAY_DEBOUNCE_MS) return
        lastOverlayShownAt = now
        showOverlay(phone, contactName, preferCache)
    }

    // ✅ Icon size helper (change dp here anytime)
    private fun setLeftIconSize(tv: TextView?, drawableRes: Int, dp: Int, tintColor: Int? = null) {
        if (tv == null) return
        val d = ContextCompat.getDrawable(this, drawableRes) ?: return
        val px = (dp * resources.displayMetrics.density).toInt()
        d.setBounds(0, 0, px, px)

        if (tintColor != null) {
            val wrap = DrawableCompat.wrap(d)
            DrawableCompat.setTint(wrap, tintColor)
        }
        tv.setCompoundDrawables(d, null, null, null)
        tv.compoundDrawablePadding = (8 * resources.displayMetrics.density).toInt()
    }

    private fun showOverlay(phone: String, contactName: String, preferCache: Boolean) {
        removeOverlay()

        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val v = inflater.inflate(R.layout.tringo_overlay, null)
        overlayView = v

        val rootFull = v.findViewById<View?>(R.id.overlayRootFull)
        val rootCard = v.findViewById<View?>(R.id.rootCard)
        val closeBtn = v.findViewById<View?>(R.id.closeBtn)

        val outsideLayer = v.findViewById<View?>(R.id.outsideCloseLayer)
        outsideLayer?.visibility = View.GONE

        val headerBusiness = v.findViewById<View?>(R.id.headerBusiness)
        val headerPerson = v.findViewById<View?>(R.id.headerPerson)

        val businessTv = v.findViewById<TextView?>(R.id.businessNameText)
        val personTv = v.findViewById<TextView?>(R.id.personNameText)
        val metaBizTv = v.findViewById<TextView?>(R.id.metaText)
        val metaPersonTv = v.findViewById<TextView?>(R.id.personMetaText)
        val smallTop = v.findViewById<TextView?>(R.id.smallTopText)

        val logoBiz = v.findViewById<ImageView?>(R.id.logoImageBusiness)
        val logoPerson = v.findViewById<ImageView?>(R.id.logoImagePerson)

        val divider = v.findViewById<View?>(R.id.dividerLine)
        val adsTitleTv = v.findViewById<TextView?>(R.id.adsTitle)
        val recycler = v.findViewById<RecyclerView?>(R.id.adsRecycler)

        val callBtn = v.findViewById<TextView?>(R.id.callBtn)
        val chatBtn = v.findViewById<TextView?>(R.id.chatBtn)

        // ✅ icon size 18dp (change to 16/14 if needed)
        setLeftIconSize(callBtn, R.drawable.ic_call_png, 18)
        setLeftIconSize(chatBtn, R.drawable.ic_whatsapp_png, 18)

        recycler?.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        adsAdapter = OverlayAdsAdapter()
        recycler?.adapter = adsAdapter

        smallTop?.text = if (postCallPopupMode) "Tringo Call Ended" else "Tringo Identifies"

        closeBtn?.setOnClickListener {
            markUserClosedDuringCall(pendingPhone)
            removeOverlay()
        }

        callBtn?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) dialNumber(num)
        }

        chatBtn?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) openWhatsAppChat(num)
        }

        val flags =
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            flags,
            PixelFormat.TRANSLUCENT
        ).apply { gravity = Gravity.TOP or Gravity.START }

        try {
            windowManager?.addView(v, params)
        } catch (e: Exception) {
            showCallerHeadsUp("Tringo Caller ID", if (contactName.isNotBlank()) contactName else phone, "addView_failed")
            stopSelf()
            return
        }

        centerCardExactly(rootFull, rootCard)
        attachFreeDragAnywhere(rootFull, rootCard, recycler)

        // Initial state (person fallback)
        headerBusiness?.visibility = View.GONE
        headerPerson?.visibility = View.VISIBLE
        personTv?.text = if (contactName.isNotBlank()) contactName else phone
        metaPersonTv?.text = ""
        businessTv?.text = ""
        metaBizTv?.text = ""

        fun applyAdsVisibilityNow() {
            val allowAds = postCallPopupMode
            val hasAds = cacheAdsCards.isNotEmpty()
            if (allowAds && hasAds) {
                divider?.visibility = View.VISIBLE
                adsTitleTv?.text = cacheAdsTitle
                adsTitleTv?.visibility = View.VISIBLE
                recycler?.visibility = View.VISIBLE
            } else {
                divider?.visibility = View.GONE
                adsTitleTv?.visibility = View.GONE
                recycler?.visibility = View.GONE
            }
        }

        divider?.visibility = View.GONE
        adsTitleTv?.visibility = View.GONE
        recycler?.visibility = View.GONE

        val apiPhone = normalizePhoneForApi(phone)

        if (preferCache && isCacheValidFor(apiPhone)) {
            applyCacheToUi(
                headerBusiness, headerPerson,
                businessTv, personTv,
                metaBizTv, metaPersonTv,
                logoBiz, logoPerson
            )
            adsAdapter?.submitList(cacheAdsCards)
            applyAdsVisibilityNow()
            return
        }

        // ✅✅ UPDATED: Typed API parsing (NO map()/str()/list())
        serviceScope.launch {
            try {
                val res = withContext(Dispatchers.IO) { ApiClient.api.phoneInfo(apiPhone) }
                val data = res.data

                val typeStr = data?.type.orEmpty()
                val card = data?.card

                val cardTitle = card?.title.orEmpty().trim()
                val cardSubtitle = card?.subtitle.orEmpty().trim()
                val cardImageUrl = card?.imageUrl.orEmpty().trim()

                val details = card?.details
                val cat = details?.category.orEmpty().trim()
                val opensAt = details?.opensAt.orEmpty().trim()
                val closesAt = details?.closesAt.orEmpty().trim()
                val addr = details?.address.orEmpty().trim()

                val isShop = typeStr.equals("OWNER_SHOP", true)

                val subtitleLine = listOfNotNull(
                    (if (cat.isNotBlank()) cat else null) ?: cardSubtitle.takeIf { it.isNotBlank() },
                    if (opensAt.isNotBlank() && closesAt.isNotBlank()) "$opensAt - $closesAt" else null,
                    addr.takeIf { it.isNotBlank() }
                ).joinToString(" • ")

                val ads = data?.advertisements
                val adsTitle = ads?.title.orEmpty().trim().ifBlank { "Advertisements" }

                val cards = (ads?.items ?: emptyList()).mapIndexed { idx, item ->
                    val title =
                        item.englishName?.trim().takeIf { !it.isNullOrBlank() }
                            ?: item.tamilName?.trim().takeIf { !it.isNullOrBlank() }
                            ?: "Ad ${idx + 1}"

                    val adAddr =
                        item.addressEn?.trim().takeIf { !it.isNullOrBlank() }
                            ?: item.addressTa?.trim().orEmpty()

                    val place = listOf(item.city, item.state, item.country)
                        .filter { !it.isNullOrBlank() }
                        .joinToString(", ")

                    val sub = listOf(adAddr, place).filter { it.isNotBlank() }.joinToString(" • ")

                    OverlayAdCard(
                        id = item.id ?: "ad_$idx",
                        title = title,
                        subtitle = sub,
                        rating = item.rating,
                        ratingCount = item.ratingCount,
                        openText = item.openLabel,
                        isTrusted = item.isTrusted ?: false,
                        imageUrl = item.primaryImageUrl.orEmpty()
                    )
                }

                saveCache(
                    phone = apiPhone,
                    isShop = isShop,
                    title = cardTitle.ifBlank { if (contactName.isNotBlank()) contactName else phone },
                    subtitleLine = subtitleLine,
                    imageUrl = cardImageUrl,
                    adsTitle = adsTitle,
                    adsCards = cards
                )

                applyCacheToUi(
                    headerBusiness, headerPerson,
                    businessTv, personTv,
                    metaBizTv, metaPersonTv,
                    logoBiz, logoPerson
                )
                adsAdapter?.submitList(cacheAdsCards)
                applyAdsVisibilityNow()

            } catch (e: Exception) {
                Log.e(TAG, "API failed: ${e.message}", e)
            }
        }
    }

    private fun applyCacheToUi(
        headerBusiness: View?, headerPerson: View?,
        businessTv: TextView?, personTv: TextView?,
        metaBizTv: TextView?, metaPersonTv: TextView?,
        logoBiz: ImageView?, logoPerson: ImageView?
    ) {
        if (cacheIsShop) {
            headerBusiness?.visibility = View.VISIBLE
            headerPerson?.visibility = View.GONE
            businessTv?.text = cacheTitle
            metaBizTv?.text = cacheSubtitleLine
            logoBiz?.load(cacheImageUrl) {
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }
        } else {
            headerBusiness?.visibility = View.GONE
            headerPerson?.visibility = View.VISIBLE
            personTv?.text = cacheTitle
            metaPersonTv?.text = cacheSubtitleLine
            logoPerson?.load(cacheImageUrl) {
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }
        }
    }

    private fun centerCardExactly(rootFull: View?, card: View?) {
        if (rootFull == null || card == null) return
        rootFull.post {
            card.post {
                val w = rootFull.width
                val h = rootFull.height
                val cw = card.width
                val ch = card.height
                if (w > 0 && h > 0 && cw > 0 && ch > 0) {
                    card.x = ((w - cw) / 2f).coerceAtLeast(0f)
                    card.y = ((h - ch) / 2f).coerceAtLeast(0f)
                }
            }
        }
    }

    private fun attachFreeDragAnywhere(rootFull: View?, card: View?, vararg ignoreViews: View?) {
        if (rootFull == null || card == null) return
        val ignore = ignoreViews.filterNotNull()
        val dm = resources.displayMetrics
        val screenW = dm.widthPixels
        val screenH = dm.heightPixels

        var downRawX = 0f
        var downRawY = 0f
        var startX = 0f
        var startY = 0f
        var dragging = false
        val threshold = 6f

        fun isTouchInsideIgnore(x: Float, y: Float): Boolean {
            val xi = x.toInt()
            val yi = y.toInt()
            val r = android.graphics.Rect()
            ignore.forEach { v ->
                v.getGlobalVisibleRect(r)
                if (r.contains(xi, yi)) return true
            }
            return false
        }

        rootFull.setOnTouchListener { _, ev ->
            if (isTouchInsideIgnore(ev.rawX, ev.rawY)) return@setOnTouchListener false

            when (ev.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downRawX = ev.rawX
                    downRawY = ev.rawY
                    startX = card.x
                    startY = card.y
                    dragging = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = ev.rawX - downRawX
                    val dy = ev.rawY - downRawY

                    if (!dragging) {
                        if (abs(dx) < threshold && abs(dy) < threshold) return@setOnTouchListener true
                        dragging = true
                    }

                    val cw = max(card.width, 1)
                    val ch = max(card.height, 1)

                    val maxX = (screenW - cw).toFloat().coerceAtLeast(0f)
                    val maxY = (screenH - ch).toFloat().coerceAtLeast(0f)

                    card.x = (startX + dx).coerceIn(0f, maxX)
                    card.y = (startY + dy).coerceIn(0f, maxY)

                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    dragging = false
                    true
                }
                else -> false
            }
        }
    }

    private fun removeOverlay() {
        overlayView?.let { try { windowManager?.removeView(it) } catch (_: Exception) {} }
        overlayView = null
    }

    override fun onDestroy() {
        isRunning = false
        incomingAutoHideJob?.cancel()
        incomingAutoHideJob = null
        stopWatchingForCallEnd()
        serviceJob.cancel()
        removeOverlay()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun showCallerHeadsUp(title: String, message: String, reason: String) {
        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) return

        val channelId = "tringo_call_alert"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NotificationManager::class.java)
            nm.createNotificationChannel(
                NotificationChannel(channelId, "Tringo Call Alerts", NotificationManager.IMPORTANCE_HIGH)
            )
        }

        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)

        getSystemService(NotificationManager::class.java).notify(202, builder.build())
        Log.d(TAG, "HeadsUp shown reason=$reason")
    }

    private fun openAppSettings() {
        try {
            val i = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(i)
        } catch (_: Exception) {}
    }

    private fun normalizePhoneForDial(raw: String): String {
        return raw.trim()
            .replace(" ", "")
            .replace("-", "")
            .replace("(", "")
            .replace(")", "")
    }

    private fun normalizePhoneForWhatsApp(raw: String): String {
        var p = raw.trim()
            .replace(" ", "")
            .replace("-", "")
            .replace("(", "")
            .replace(")", "")
        if (p.startsWith("+")) p = p.substring(1)
        return p
    }

    private fun dialNumber(phone: String) {
        try {
            val p = normalizePhoneForDial(phone)
            val i = Intent(Intent.ACTION_DIAL).apply {
                data = Uri.parse("tel:$p")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(i)
        } catch (e: Exception) {
            Log.e(TAG, "dialNumber failed: ${e.message}", e)
        }
    }

    private fun openWhatsAppChat(phone: String) {
        try {
            val p = normalizePhoneForWhatsApp(phone)
            if (p.isBlank()) return

            val url = "https://wa.me/$p"
            val i = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            try {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo("com.whatsapp", 0)
                i.setPackage("com.whatsapp")
            } catch (_: Exception) {}

            startActivity(i)
        } catch (e: Exception) {
            Log.e(TAG, "openWhatsAppChat failed: ${e.message}", e)
        }
    }

    private fun normalizePhoneForApi(raw: String): String {
        return raw.trim().replace(" ", "")
    }
}
