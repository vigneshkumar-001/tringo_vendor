package com.example.tringo_vendor_new

data class OverlayAdCard(
    val id: String,
    val title: String,
    val subtitle: String,
    val rating: Double? = null,
    val ratingCount: Int? = null,
    val openText: String? = null,
    val isTrusted: Boolean = false,
    val imageUrl: String = ""
)
