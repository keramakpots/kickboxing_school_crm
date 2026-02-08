package com.kickboxing.app

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

object ApiClient {

    private const val BASE_URL = "http://10.0.2.2:8080/api/entries"

    fun sendEntry(participantId: String, passId: String, locationId: String) {
        val json = """
        {
          "participantId":"",
          "passId":"",
          "locationId":""
        }
        """

        val body = json.toRequestBody("application/json".toMediaType())

        val request = Request.Builder()
            .url(BASE_URL)
            .post(body)
            .build()

        OkHttpClient().newCall(request).execute()
    }
}
