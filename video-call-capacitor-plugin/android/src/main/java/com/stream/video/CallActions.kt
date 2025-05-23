import androidx.activity.result.ActivityResultLauncher
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import android.content.Intent
import android.media.projection.MediaProjectionManager
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PresentToAll
import androidx.compose.material.icons.outlined.PresentToAll
import androidx.compose.material.icons.filled.Warning
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import io.getstream.video.android.compose.theme.VideoTheme
import io.getstream.video.android.compose.ui.components.call.controls.actions.LeaveCallAction
import io.getstream.video.android.compose.ui.components.call.controls.actions.ToggleAction
import io.getstream.video.android.compose.ui.components.call.controls.actions.ToggleCameraAction
import io.getstream.video.android.compose.ui.components.call.controls.actions.ToggleMicrophoneAction
import io.getstream.video.android.core.Call
import androidx.compose.foundation.layout.Box
import androidx.compose.material.icons.filled.Videocam
import androidx.compose.material.icons.filled.VideocamOff
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.MicOff
import androidx.compose.material.Icon
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.zIndex

@Composable
fun CallActions(
    call: Call,
    isCameraEnabled: Boolean,
    isMicrophoneEnabled: Boolean,
    isScreenShareEnabled: Boolean,
    isCameraPermissionGranted: Boolean,
    isMicrophonePermissionGranted: Boolean,
    isCameraPermanentlyDenied: Boolean = false,
    isMicrophonePermanentlyDenied: Boolean = false,
    startScreenShare: ActivityResultLauncher<Intent>,
    mediaProjectionManager: MediaProjectionManager,
    onCallLeave: () -> Unit = {},
    onRequestCameraPermission: () -> Unit = {},
    onRequestMicrophonePermission: () -> Unit = {},
) {
    // Define error color
    val errorColor = Color.Red

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(60.dp)
            .padding(top = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center
    ){
        LeaveCallAction(
            modifier = Modifier.size(62.dp),
            onCallAction = {
                onCallLeave()
            }
        )

        // Custom camera toggle with permission warning if needed
        Box(
            modifier = Modifier.size(52.dp),
            contentAlignment = Alignment.Center
        ) {
            if (!isCameraPermissionGranted) {
                // Custom toggle for denied camera permission
                ToggleAction(
                    modifier = Modifier.size(52.dp),
                    enabled = true,
                    shape = null,
                    enabledColor = errorColor,
                    disabledColor = errorColor,
                    enabledIconTint = Color.White,
                    disabledIconTint = Color.White,
                    isActionActive = false,
                    iconOnOff = Pair(Icons.Filled.Videocam, Icons.Filled.VideocamOff),
                    onAction = { onRequestCameraPermission() }
                )
                
                // Warning icon with different appearance if permanently denied
                Icon(
                    imageVector = Icons.Filled.Warning,
                    contentDescription = if (isCameraPermanentlyDenied) 
                        "Open settings to grant camera permission" 
                    else 
                        "Camera permission required",
                    modifier = Modifier
                        .size(18.dp)
                        .align(Alignment.TopEnd)
                        .zIndex(2f)
                        .alpha(if (isCameraPermanentlyDenied) 1f else 0.8f)
                        .scale(if (isCameraPermanentlyDenied) 1.2f else 1f),
                    tint = Color.White
                )
            } else {
                // Standard toggle for granted camera permission
                ToggleCameraAction(
                    modifier = Modifier.size(52.dp),
                    isCameraEnabled = isCameraEnabled,
                    onCallAction = { call.camera.setEnabled(it.isEnabled) }
                )
            }
        }

        // Custom microphone toggle with permission warning if needed
        Box(
            modifier = Modifier.size(52.dp),
            contentAlignment = Alignment.Center
        ) {
            if (!isMicrophonePermissionGranted) {
                // Custom toggle for denied microphone permission
                ToggleAction(
                    modifier = Modifier.size(52.dp),
                    enabled = true,
                    shape = null,
                    enabledColor = errorColor,
                    disabledColor = errorColor,
                    enabledIconTint = Color.White,
                    disabledIconTint = Color.White,
                    isActionActive = false,
                    iconOnOff = Pair(Icons.Filled.Mic, Icons.Filled.MicOff),
                    onAction = { onRequestMicrophonePermission() }
                )
                
                // Warning icon with different appearance if permanently denied
                Icon(
                    imageVector = Icons.Filled.Warning,
                    contentDescription = if (isMicrophonePermanentlyDenied) 
                        "Open settings to grant microphone permission" 
                    else 
                        "Microphone permission required",
                    modifier = Modifier
                        .size(18.dp)
                        .align(Alignment.TopEnd)
                        .zIndex(2f)
                        .alpha(if (isMicrophonePermanentlyDenied) 1f else 0.8f)
                        .scale(if (isMicrophonePermanentlyDenied) 1.2f else 1f),
                    tint = Color.White
                )
            } else {
                // Standard toggle for granted microphone permission
                ToggleMicrophoneAction(
                    modifier = Modifier.size(52.dp),
                    isMicrophoneEnabled = isMicrophoneEnabled,
                    onCallAction = { call.microphone.setEnabled(it.isEnabled) }
                )
            }
        }

        ToggleAction(
            modifier = Modifier.size(52.dp),
            enabled = true,
            shape = null,
            enabledColor = Color.White,
            disabledColor = VideoTheme.colors.buttonPrimaryDefault,
            enabledIconTint = Color.Black,
            disabledIconTint = Color.White,
            isActionActive = isScreenShareEnabled,
            iconOnOff = Pair(Icons.Filled.PresentToAll, Icons.Outlined.PresentToAll),
            onAction = {
                if (isScreenShareEnabled) {
                    call.stopScreenSharing()
                } else {
                    startScreenShare.launch(
                        mediaProjectionManager.createScreenCaptureIntent()
                    )
                }
            }
        )
    }
}
