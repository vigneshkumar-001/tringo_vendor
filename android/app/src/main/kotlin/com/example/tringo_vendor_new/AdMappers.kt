package com.example.tringo_vendor_new

// ✅ updated type name
fun OverlayAdItem.toOverlayCard(): OverlayAdCard {
    val title = (englishName?.trim().takeUnless { it.isNullOrBlank() }
        ?: tamilName?.trim().takeUnless { it.isNullOrBlank() }
        ?: "Advertisement")

    val addr = (addressEn?.trim().takeUnless { it.isNullOrBlank() }
        ?: addressTa?.trim().takeUnless { it.isNullOrBlank() }
        ?: "")

    val place = listOfNotNull(
        city?.trim()?.takeIf { it.isNotBlank() },
        state?.trim()?.takeIf { it.isNotBlank() },
        country?.trim()?.takeIf { it.isNotBlank() }
    ).joinToString(", ")

    val subtitle = listOf(
        addr.takeIf { it.isNotBlank() },
        place.takeIf { it.isNotBlank() }
    ).filterNotNull().joinToString(" • ")

    return OverlayAdCard(
        id = id ?: "",
        title = title,
        subtitle = subtitle,
        rating = rating,
        ratingCount = ratingCount,
        openText = openLabel,
        isTrusted = isTrusted ?: false,
        imageUrl = primaryImageUrl ?: ""
    )
}
