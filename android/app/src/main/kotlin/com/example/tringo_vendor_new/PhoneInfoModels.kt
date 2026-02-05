package com.example.tringo_vendor_new

import com.google.gson.annotations.SerializedName

data class PhoneInfoResponse(
    @SerializedName("status") val status: Boolean? = null,
    @SerializedName("message") val message: String? = null,
    @SerializedName("data") val data: PhoneInfoData? = null
)

data class PhoneInfoData(
    @SerializedName("query") val query: String? = null,
    @SerializedName("type") val type: String? = null,
    @SerializedName("card") val card: PhoneInfoCard? = null,
    @SerializedName("advertisements") val advertisements: AdsBlock? = null
)

data class PhoneInfoCard(
    @SerializedName("title") val title: String? = null,
    @SerializedName("subtitle") val subtitle: String? = null,
    @SerializedName("phone") val phone: String? = null,
    @SerializedName("imageUrl") val imageUrl: String? = null,
    @SerializedName("details") val details: PhoneInfoDetails? = null
)

data class PhoneInfoDetails(
    @SerializedName("userId") val userId: String? = null,
    @SerializedName("role") val role: String? = null,
    @SerializedName("shopId") val shopId: String? = null,
    @SerializedName("category") val category: String? = null,
    @SerializedName("opensAt") val opensAt: String? = null,
    @SerializedName("closesAt") val closesAt: String? = null,
    @SerializedName("address") val address: String? = null,
    @SerializedName("distanceKm") val distanceKm: Double? = null,
    @SerializedName("distanceLabel") val distanceLabel: String? = null,
    @SerializedName("rating") val rating: Double? = null,
    @SerializedName("ratingCount") val ratingCount: Int? = null,
    @SerializedName("reviewCount") val reviewCount: Int? = null
)

data class AdsBlock(
    @SerializedName("title") val title: String? = null,
    @SerializedName("layout") val layout: String? = null,
    @SerializedName("items") val items: List<AdItem>? = null
)

// ✅ KEEP ONLY THIS AdItem (delete AdItem.kt)
data class AdItem(
    @SerializedName("id") val id: String? = null,
    @SerializedName("englishName") val englishName: String? = null,
    @SerializedName("tamilName") val tamilName: String? = null,
    @SerializedName("category") val category: String? = null,
    @SerializedName("subCategory") val subCategory: String? = null,
    @SerializedName("city") val city: String? = null,
    @SerializedName("state") val state: String? = null,
    @SerializedName("country") val country: String? = null,
    @SerializedName("addressEn") val addressEn: String? = null,
    @SerializedName("addressTa") val addressTa: String? = null,
    @SerializedName("rating") val rating: Double? = null,
    @SerializedName("ratingCount") val ratingCount: Int? = null,
    @SerializedName("isTrusted") val isTrusted: Boolean? = null,
    @SerializedName("openLabel") val openLabel: String? = null,
    @SerializedName("primaryPhone") val primaryPhone: String? = null,
    @SerializedName("primaryImageUrl") val primaryImageUrl: String? = null,
    @SerializedName("distanceLabel") val distanceLabel: String? = null
)
