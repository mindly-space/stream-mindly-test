package com.stream.video

import android.content.Intent
import android.util.Log
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.annotation.CapacitorPlugin
import com.getcapacitor.PluginMethod


@CapacitorPlugin(name = "StreamVideoCallCapacitor")
class StreamVideoCallCapacitorPlugin : Plugin() {

    companion object {
        var instance: StreamVideoCallCapacitorPlugin? = null
    }

    override fun load() {
        instance = this
    }

    private lateinit var apiKey: String
    private lateinit var token: String

    private lateinit var userId: String
    private lateinit var userName: String
    private var userImageURL: String? = null

    private lateinit var callId: String

    /**
     * Initialize the video call client.
     * Expects parameters:
     * - apiKey: String
     * - token: String
     * - user: JSObject with keys "id", "name", and optionally "imageURL"
     * - preferredExtension (optional): String
     */
    @PluginMethod
    fun initializeVideoCall(call: PluginCall) {
        Log.i("StreamVideoCall", "Call initializeVideoCall")

        val apiKey = call.getString("apiKey") ?: run {
            Log.e("StreamVideoCall", "API Key is required")
            call.reject("API Key is required")
            return
        }
        this.apiKey = apiKey

        val token = call.getString("token") ?: run {
            Log.e("StreamVideoCall", "Token is required")
            call.reject("Token is required")
            return
        }
        this.token = token

        val userObject = call.getObject("user") ?: run {
            Log.e("StreamVideoCall", "User is required")
            call.reject("User is required")
            return
        }
        val userId = userObject.getString("id") ?: run {
            Log.e("StreamVideoCall", "User id is required")
            call.reject("User id is required")
            return
        }
        this.userId = userId

        val userName = userObject.getString("name") ?: run {
            Log.e("StreamVideoCall", "User name is required")
            call.reject("User name is required")
            return
        }
        this.userName = userName

        this.userImageURL = userObject.getString("imageURL")

        Log.i("StreamVideoCall", "Android Call initializeVideoCall resolve")
        call.resolve()
    }

    /**
     * Join the video call.
     * Expects parameters:
     * - callId: String
     *
     * This method launches a full-screen activity (VideoCallActivity) that hosts the video call UI.
     */
    @PluginMethod
    fun joinCall(call: PluginCall) {
        Log.i("StreamVideoCall", "Call joinCall")

        // Ensure UI updates run on the main thread
        activity?.runOnUiThread {
            val callId = call.getString("callId") ?: run {
                Log.e("StreamVideoCall", "Call id not found")
                call.reject("Call id not found")
                return@runOnUiThread
            }
            this.callId = callId

            // Create an intent to launch the video call UI
            val intent = Intent(context, VideoCallActivity::class.java).apply {
                putExtra("apiKey", apiKey)
                putExtra("token", token)
                putExtra("userId", userId)
                putExtra("userName", userName)
                putExtra("userImageURL", userImageURL)
                putExtra("callId", callId)
                // Add flags for modal-like behavior
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }

            // Emit event before launching the activity
            notifyListeners("callJoined", JSObject().apply {
                put("callId", callId)
                put("userId", userId)
            })

            // Launch the full-screen VideoCallActivity.
            context.startActivity(intent)
            call.resolve()
        }
    }

    fun onCallEnded(callId: String) {
        Log.i("StreamVideoCall", "Call ended event triggered")
        notifyListeners("callEnded", JSObject().apply {
            put("callId", callId)
        })
    }
}