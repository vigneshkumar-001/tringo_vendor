package com.example.tringo_vendor_new

import android.util.Log
import com.google.gson.GsonBuilder
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object ApiClient {

    private const val BASE_URL = "https://bknd.tringobiz.com/"
    private const val TAG = "TRINGO_HTTP"

    private val rawBodyLogger: Interceptor = Interceptor { chain ->
        val req = chain.request()
        Log.d(TAG, "→ ${req.method} ${req.url}")

        val res: Response = chain.proceed(req)
        Log.d(TAG, "← ${res.code} ${res.request.url}")

        try {
            val peek = res.peekBody(1024 * 1024)
            val bodyStr = peek.string()
            Log.d(TAG, "BODY: ${if (bodyStr.isNotBlank()) bodyStr else "<empty>"}")
        } catch (e: Exception) {
            Log.e(TAG, "peekBody failed: ${e.message}")
        }
        res
    }

    private val gson = GsonBuilder()
        .setLenient()
        .serializeNulls()
        .create()

    private val okHttp: OkHttpClient by lazy {
        OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS)
            .writeTimeout(20, TimeUnit.SECONDS)
            .retryOnConnectionFailure(true)
            .addInterceptor(rawBodyLogger)
            .build()
    }

    val api: TringoApi by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(okHttp)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()
            .create(TringoApi::class.java)
    }
}
