package com.example.tringo_vendor_new


data class CallerLookupResponse(
    val isBusiness: Boolean? = null,
    val personName: String? = null,
    val businessName: String? = null,
    val rating: Double? = null,
    val openText: String? = null,
    val category: String? = null,
    val ads: List<AdItem> = emptyList()
)
