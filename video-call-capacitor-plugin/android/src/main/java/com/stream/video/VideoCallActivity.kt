package com.stream.video

import CallActions
import android.Manifest
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.result.contract.ActivityResultContracts.RequestPermission
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.filled.Headphones
import androidx.compose.material.icons.filled.PhoneInTalk
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import io.getstream.android.video.generated.models.AudioSettingsRequest
import io.getstream.android.video.generated.models.AudioSettingsRequest.DefaultDevice.Speaker
import io.getstream.android.video.generated.models.CallSettingsRequest
import io.getstream.android.video.generated.models.ScreensharingSettingsRequest
import io.getstream.android.video.generated.models.TargetResolution
import io.getstream.android.video.generated.models.VideoSettingsRequest
import io.getstream.android.video.generated.models.VideoSettingsRequest.CameraFacing.Front
import io.getstream.video.android.compose.permission.rememberCallPermissionsState
import io.getstream.video.android.compose.theme.VideoTheme
import io.getstream.video.android.compose.ui.components.call.CallAppBar
import io.getstream.video.android.core.GEO
import io.getstream.video.android.core.StreamVideoBuilder
import io.getstream.video.android.model.User
import io.getstream.video.android.compose.ui.components.call.activecall.CallContent
import io.getstream.video.android.compose.ui.components.call.controls.actions.FlipCameraAction
import io.getstream.video.android.compose.ui.components.call.controls.actions.ToggleAction
import io.getstream.video.android.compose.ui.components.call.renderer.FloatingParticipantVideo
import io.getstream.video.android.compose.ui.components.call.renderer.LayoutType
import io.getstream.video.android.compose.ui.components.call.renderer.ParticipantVideo
import io.getstream.video.android.compose.ui.components.call.renderer.ParticipantsLayout
import io.getstream.video.android.compose.ui.components.call.renderer.RegularVideoRendererStyle
import io.getstream.video.android.compose.ui.components.call.renderer.VideoRendererStyle
import io.getstream.video.android.core.Call
import io.getstream.video.android.core.CreateCallOptions
import io.getstream.video.android.core.ParticipantState
import io.getstream.video.android.core.StreamVideo
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import android.os.Build
import io.getstream.video.android.compose.ui.components.video.VideoScalingType
import android.content.res.Configuration
import androidx.compose.ui.platform.LocalContext

class VideoCallActivity : ComponentActivity() {
    private lateinit var callInstance: Call

    // Use mutable state for permissions that will be accessed from Compose
    private val cameraPermissionState = mutableStateOf(false)
    private val microphonePermissionState = mutableStateOf(false)
    private val cameraPermanentlyDenied = mutableStateOf(false)
    private val microphonePermanentlyDenied = mutableStateOf(false)
    
    // Track if we've already sent users to settings
    private var hasShownCameraSettings = false
    private var hasShownMicrophoneSettings = false
    
    // Permission launchers for individual permissions
    private val requestCameraPermission = registerForActivityResult(RequestPermission()) { isGranted ->
        // Update camera permission state and enable camera if granted
        lifecycleScope.launch {
            cameraPermissionState.value = isGranted
            if (isGranted) {
                callInstance.camera.setEnabled(true)
                cameraPermanentlyDenied.value = false
            } else {
                // Check if permission is permanently denied (user clicked "Don't ask again")
                val permanentlyDenied = !shouldShowRequestPermissionRationale(Manifest.permission.CAMERA)
                cameraPermanentlyDenied.value = permanentlyDenied
                
                // Make sure camera is disabled if permission is denied
                callInstance.camera.setEnabled(false)
                
                // If permission is permanently denied, show a toast
                if (permanentlyDenied) {
                    Toast.makeText(
                        this@VideoCallActivity,
                        "Camera permission denied. Please enable in settings.",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
        }
    }
    
    private val requestMicrophonePermission = registerForActivityResult(RequestPermission()) { isGranted ->
        // Update microphone permission state and enable microphone if granted
        lifecycleScope.launch {
            microphonePermissionState.value = isGranted
            if (isGranted) {
                callInstance.microphone.setEnabled(true)
                microphonePermanentlyDenied.value = false
            } else {
                // Check if permission is permanently denied (user clicked "Don't ask again")
                val permanentlyDenied = !shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO)
                microphonePermanentlyDenied.value = permanentlyDenied
                
                // Make sure microphone is disabled if permission is denied
                callInstance.microphone.setEnabled(false)
                
                // If permission is permanently denied, show a toast
                if (permanentlyDenied) {
                    Toast.makeText(
                        this@VideoCallActivity,
                        "Microphone permission denied. Please enable in settings.",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
        }
    }
    
    // Function to open app settings
    private fun openAppSettings(forCamera: Boolean = false, forMicrophone: Boolean = false) {
        // Track that we've shown settings
        if (forCamera) {
            hasShownCameraSettings = true
        }
        if (forMicrophone) {
            hasShownMicrophoneSettings = true
        }
        
        Toast.makeText(
            this, 
            "Please enable permissions in Settings to use this feature", 
            Toast.LENGTH_LONG
        ).show()
        
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(this)
        }
    }

    // Add these variables to track previous permission states
    private var previousMicrophonePermissionState = false
    private var previousCameraPermissionState = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Keep screen on during the call
        window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        Log.d("StreamVideoCallActivity", "onCreate called")

        // Add this code to initialize the permission states
        cameraPermissionState.value = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
        
        microphonePermissionState.value = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        
        // Initialize previous states
        previousCameraPermissionState = cameraPermissionState.value
        previousMicrophonePermissionState = microphonePermissionState.value

        val apiKey = intent.getStringExtra("apiKey") ?: return
        val token = intent.getStringExtra("token") ?: return

        val userId = intent.getStringExtra("userId") ?: return
        val userName = intent.getStringExtra("userName") ?: return
        val userImageURL = intent.getStringExtra("userImageURL") ?: return

        val callId = intent.getStringExtra("callId") ?: return

        val user = User(
            id = userId,
            name = userName,
            image = userImageURL
        )

        val client = StreamVideoBuilder(
            context = applicationContext,
            apiKey = apiKey,
            geo = GEO.GlobalEdgeNetwork,
            user = user,
            token = token,
        ).build()

        callInstance = client.call(type = "default", id = callId)

        val startScreenShare =
            registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
                if (result.resultCode == RESULT_OK && result.data != null) {
                    callInstance.startScreenSharing(result.data!!)
                } else {
                    Toast.makeText(this, "Screen sharing permission denied", Toast.LENGTH_SHORT)
                        .show()
                }
            }

        setContent {
            var controlsVisible by remember { mutableStateOf(true) }

            val mediaProjectionManager = remember {
                getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            }

            // Replace LaunchCallPermissions with rememberCallPermissionsState for better control
            val permissionState = rememberCallPermissionsState(
                call = callInstance,
                permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    listOf(
                        Manifest.permission.CAMERA,
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.BLUETOOTH_CONNECT
                    )
                } else {
                    listOf(
                        Manifest.permission.CAMERA,
                        Manifest.permission.RECORD_AUDIO
                    )
                },
                onPermissionsResult = { permissionResults ->
                    // Check which permissions were granted
                    val cameraGranted = permissionResults[Manifest.permission.CAMERA] == true
                    val microphoneGranted = permissionResults[Manifest.permission.RECORD_AUDIO] == true
                    
                    // Start the call regardless of permissions
                    lifecycleScope.launch {
                        // Log permission status
                        Log.d("StreamVideoCallActivity", "Camera permission: ${if (cameraGranted) "granted" else "denied"}")
                        Log.d("StreamVideoCallActivity", "Microphone permission: ${if (microphoneGranted) "granted" else "denied"}")
                        
                        val result = callInstance.join(
                            create = true,
                            createOptions = CreateCallOptions(
                                settings = CallSettingsRequest(
                                    screensharing = ScreensharingSettingsRequest(
                                        accessRequestEnabled = true,
                                        enabled = true,
                                        targetResolution = TargetResolution(
                                            width = 1280,
                                            height = 720,
                                        )
                                    ),
                                    video = VideoSettingsRequest(
                                        accessRequestEnabled = true,
                                        cameraDefaultOn = cameraGranted, // Only enable camera by default if permission granted
                                        enabled = cameraGranted, // Only enable video if permission granted
                                        cameraFacing = Front,
                                        targetResolution = TargetResolution(
                                            width = 1280,
                                            height = 720,
                                            bitrate = 1500000
                                        )
                                    ),
                                    audio = AudioSettingsRequest(
                                        defaultDevice = Speaker,
                                        accessRequestEnabled = true,
                                        micDefaultOn = true, // Always enable mic by default
                                        speakerDefaultOn = true,
                                        noiseCancellation = null,
                                        opusDtxEnabled = true,
                                        redundantCodingEnabled = true
                                    )
                                )
                            )
                        )
                        result.onError {
                            Toast.makeText(applicationContext, it.message, Toast.LENGTH_LONG).show()
                        }
                    }
                }
            )
            
            // Launch permission request immediately when the screen opens
            LaunchedEffect(Unit) {
                permissionState.launchPermissionRequest()
            }

            VideoTheme {
                val isCameraEnabled by callInstance.camera.isEnabled.collectAsState()
                val isMicrophoneEnabled by callInstance.microphone.isEnabled.collectAsState()
                val isScreenShareEnabled by callInstance.screenShare.isEnabled.collectAsState()
                val screenSharingSession =
                    callInstance.state.screenSharingSession.collectAsStateWithLifecycle()
                val screenSharing = screenSharingSession.value

                val speaker = callInstance.speaker
                val speakerDevice by speaker.selectedDevice.collectAsState()
                val speakerIcon = when (speakerDevice?.name) {
                    "Speakerphone" -> Icons.AutoMirrored.Filled.VolumeUp
                    "Earpiece"     -> Icons.Filled.PhoneInTalk
                    "Bluetooth"    -> Icons.Filled.Headphones
                    else           -> Icons.AutoMirrored.Filled.VolumeUp
                }
                
                val me by callInstance.state.me.collectAsState()
                var parentSize: IntSize by remember { mutableStateOf(IntSize(0, 0)) }

                // Observe the activity-level permission state values
                val cameraPermissionGranted by cameraPermissionState
                val microphonePermissionGranted by microphonePermissionState
                val isCameraPermanentlyDenied by cameraPermanentlyDenied
                val isMicrophonePermanentlyDenied by microphonePermanentlyDenied
                
                // Update permission state from the permissionState result
                LaunchedEffect(permissionState.allPermissionsGranted) {
                    // Update our activity-level state when permissions status changes
                    cameraPermissionState.value = ContextCompat.checkSelfPermission(
                        this@VideoCallActivity,
                        Manifest.permission.CAMERA
                    ) == PackageManager.PERMISSION_GRANTED
                    
                    microphonePermissionState.value = ContextCompat.checkSelfPermission(
                        this@VideoCallActivity,
                        Manifest.permission.RECORD_AUDIO
                    ) == PackageManager.PERMISSION_GRANTED
                    
                    // Update permanently denied states
                    if (!cameraPermissionState.value) {
                        cameraPermanentlyDenied.value = !shouldShowRequestPermissionRationale(Manifest.permission.CAMERA)
                    }
                    
                    if (!microphonePermissionState.value) {
                        microphonePermanentlyDenied.value = !shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO)
                    }
                }

                CallContent(
                    modifier = Modifier.fillMaxSize(),
                    call = callInstance,
                    onBackPressed = { onCallEnd() },
                    enableInPictureInPicture = true,
                    appBarContent = @Composable { call: Call ->
                        AnimatedVisibility(
                            visible = (screenSharing != null && !screenSharing.participant.isLocal) || controlsVisible,
                            enter = slideInVertically(
                                initialOffsetY = { -it }
                            ) + fadeIn(),
                            exit = slideOutVertically(
                                targetOffsetY = { -it }
                            ) + fadeOut()
                        ) {
                            Box(modifier = Modifier.statusBarsPadding()) {
                                CallAppBar(
                                    call = call,
                                    leadingContent = {
                                            FlipCameraAction(
                                                modifier = Modifier.size(52.dp),
                                                onCallAction = { call.camera.flip() }
                                            )
                                    },
                                    trailingContent = {
                                            ToggleAction(
                                                modifier = Modifier.size(52.dp),
                                                enabled = true,
                                                shape = null,
                                                enabledColor = VideoTheme.colors.buttonPrimaryDefault,
                                                disabledColor = VideoTheme.colors.buttonPrimaryDefault,
                                                enabledIconTint = VideoTheme.colors.iconDefault,
                                                disabledIconTint = VideoTheme.colors.iconDefault,
                                                isActionActive = true,
                                                iconOnOff = Pair(speakerIcon, speakerIcon),
                                            ) {
                                                if (speakerDevice?.name == "Speakerphone") {
                                                    speaker.setSpeakerPhone(false)
                                                } else {
                                                    speaker.setSpeakerPhone(true)
                                                }
                                            }
                                    }
                                )
                            }
                        }
                    },
                    videoContent = @Composable { call: Call ->
                        ParticipantsLayout(
                            layoutType = LayoutType.DYNAMIC,
                            call = call,
                            modifier = Modifier
                                .fillMaxSize()
                                .weight(1f)
                                .padding(bottom = VideoTheme.dimens.spacingXXs)
                                .onSizeChanged { parentSize = it },
                            videoRenderer = @Composable { modifier: Modifier, call: Call, participant: ParticipantState, style: VideoRendererStyle ->
                                Box(modifier = modifier.clickable {
                                    controlsVisible = !controlsVisible
                                }) {
                                    ParticipantVideo(
                                        call = call,
                                        participant = participant,
                                        style = style,
                                        actionsContent = { _, _, _ -> },
                                        scalingType = VideoScalingType.SCALE_ASPECT_FIT
                                    )
                                }
                            },
                            floatingVideoRenderer = @Composable { call: Call, IntSize ->
                                val configuration = LocalContext.current.resources.configuration
                                val isLandscape = configuration.orientation == Configuration.ORIENTATION_LANDSCAPE
                                FloatingParticipantVideo(
                                    modifier = Modifier.align(Alignment.TopEnd),
                                    call = call,
                                    participant = me!!,
                                    parentBounds = parentSize,
                                    style = RegularVideoRendererStyle(
                                        isShowingConnectionQualityIndicator = true,
                                        isShowingParticipantLabel = true
                                    ),
                                    videoRenderer = { participant ->
                                        ParticipantVideo(
                                            call = call,
                                            participant = participant,
                                            style = RegularVideoRendererStyle(
                                                isShowingConnectionQualityIndicator = true,
                                                isShowingParticipantLabel = true
                                            ),
                                            actionsContent = { _, _, _ -> },
                                            scalingType = if (isLandscape) {
                                                VideoScalingType.SCALE_ASPECT_FIT
                                            } else {
                                                VideoScalingType.SCALE_ASPECT_FILL
                                            }
                                        )
                                    }
                                )
                            },
                        )
                    },
                    controlsContent = @Composable {
                        AnimatedVisibility(
                            visible = (screenSharing != null && !screenSharing.participant.isLocal) || controlsVisible,
                            enter = slideInVertically(
                                initialOffsetY = { it }
                            ) + fadeIn(),
                            exit = slideOutVertically(
                                targetOffsetY = { it }
                            ) + fadeOut()
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .navigationBarsPadding()
                                    .padding(top = 8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                CallActions(
                                    call = callInstance,
                                    isCameraEnabled = isCameraEnabled,
                                    isMicrophoneEnabled = isMicrophoneEnabled,
                                    isScreenShareEnabled = isScreenShareEnabled,
                                    isCameraPermissionGranted = cameraPermissionGranted,
                                    isMicrophonePermissionGranted = microphonePermissionGranted,
                                    isCameraPermanentlyDenied = isCameraPermanentlyDenied,
                                    isMicrophonePermanentlyDenied = isMicrophonePermanentlyDenied,
                                    startScreenShare = startScreenShare,
                                    mediaProjectionManager = mediaProjectionManager,
                                    onCallLeave = { onCallEnd() },
                                    onRequestCameraPermission = {
                                        // If permission is permanently denied, open settings
                                        if (isCameraPermanentlyDenied) {
                                            openAppSettings(forCamera = true)
                                        } else {
                                            requestCameraPermission.launch(Manifest.permission.CAMERA)
                                        }
                                    },
                                    onRequestMicrophonePermission = {
                                        // If permission is permanently denied, open settings
                                        if (isMicrophonePermanentlyDenied) {
                                            openAppSettings(forMicrophone = true)
                                        } else {
                                            requestMicrophonePermission.launch(Manifest.permission.RECORD_AUDIO)
                                        }
                                    }
                                )
                            }
                        }
                    }
                )
            }
        }
    }

    override fun onPause() {
        Log.d("StreamVideoCallActivity", "onPause")
        super.onPause()
    }

    override fun onStop() {
        Log.d("StreamVideoCallActivity", "onStop")
        super.onStop()
    }

    override fun onDestroy() {
        Log.d("StreamVideoCallActivity", "onDestroy")
        onCallEnd()
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        Log.d("StreamVideoCallActivity", "onResume")
        
        // Check if permissions were granted in settings
        checkAndUpdatePermissions()
    }
    
    private fun checkAndUpdatePermissions() {
        // Check current permission states
        val hasCameraPermission = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
        
        val hasMicrophonePermission = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        
        // Check if permissions have changed
        val cameraPermissionChanged = hasCameraPermission != previousCameraPermissionState
        val microphonePermissionChanged = hasMicrophonePermission != previousMicrophonePermissionState
        
        // Update permission states
        cameraPermissionState.value = hasCameraPermission
        microphonePermissionState.value = hasMicrophonePermission
        
        // If permissions are now granted, reset permanently denied flags
        if (hasCameraPermission) {
            cameraPermanentlyDenied.value = false
            
            // Only enable camera if permission just changed from denied to granted
            if (cameraPermissionChanged && !previousCameraPermissionState) {
                lifecycleScope.launch {
                    Log.d("StreamVideoCallActivity", "Camera permission newly granted, checking state")
                    val isEnabled = callInstance.camera.isEnabled.value
                    Log.d("StreamVideoCallActivity", "Camera currently enabled: $isEnabled")
                }
            }
        } else {
            // Make sure camera is disabled if permission is denied
            lifecycleScope.launch {
                callInstance.camera.setEnabled(false)
            }
        }
        
        if (hasMicrophonePermission) {
            microphonePermanentlyDenied.value = false
            
            // Only enable microphone if permission just changed from denied to granted
            if (microphonePermissionChanged && !previousMicrophonePermissionState) {
                lifecycleScope.launch {
                    callInstance.microphone.setEnabled(true)
                    Log.d("StreamVideoCallActivity", "Microphone permission newly granted, mic enabled automatically")
                }
            }
        } else {
            // Make sure microphone is disabled if permission is denied
            lifecycleScope.launch {
                callInstance.microphone.setEnabled(false)
            }
        }
        
        // Update previous states for next comparison
        previousCameraPermissionState = hasCameraPermission
        previousMicrophonePermissionState = hasMicrophonePermission
    }

    private fun onCallEnd() {
        try {
            Log.d("StreamVideoCallActivity", "Leave call")
            // Clear the keep screen on flag
            window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            
            callInstance.leave()
            StreamVideo.removeClient()

            StreamVideoCallCapacitorPlugin.instance?.onCallEnded(callInstance.id)
                ?: Log.e("StreamVideoCallActivity", "Plugin instance not found")

        } catch (e: Exception) {
            Log.e("StreamVideoCallActivity", "Error leaving call: ${e.message}")
        } finally {
            finish()
        }
    }
}
