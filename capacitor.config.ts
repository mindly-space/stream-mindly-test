const config = {
  appId: 'com.mindly.stream.video.call',
  appName: 'Mindly Stream Video Call',
  webDir: 'build',
  plugins: {
    SplashScreen: {
      launchAutoHide: true,
      backgroundColor: '#0288D1',
    },
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert'],
    },
    Keyboard: {
      resize: 'body',
      style: 'dark',
      resizeOnFullScreen: true,
    },
  },
  cordova: {},
  server: {
    iosScheme: 'ionic',
  },
};

export default config;
