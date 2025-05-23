import React, { useState, useEffect } from 'react';
import {
  IonApp,
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar,
  IonItem,
  IonLabel,
  IonInput,
  IonButton,
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardTitle,
  IonToast,
  setupIonicReact,
} from '@ionic/react';
import { StreamVideoCallCapacitor } from '@mindly/stream-video-call-capacitor';

// Core CSS required for Ionic components to work properly
import '@ionic/react/css/core.css';

// Basic CSS for apps built with Ionic
import '@ionic/react/css/normalize.css';
import '@ionic/react/css/structure.css';
import '@ionic/react/css/typography.css';

// Optional CSS utils that can be commented out
import '@ionic/react/css/padding.css';
import '@ionic/react/css/float-elements.css';
import '@ionic/react/css/text-alignment.css';
import '@ionic/react/css/text-transformation.css';
import '@ionic/react/css/flex-utils.css';
import '@ionic/react/css/display.css';

setupIonicReact();

const App: React.FC = () => {
  const [apiKey, setApiKey] = useState('');
  const [token, setToken] = useState('');
  const [userId, setUserId] = useState('');
  const [userName, setUserName] = useState('');
  const [userImageURL, setUserImageURL] = useState('');
  const [callId, setCallId] = useState('');
  const [isInitialized, setIsInitialized] = useState(false);
  const [showToast, setShowToast] = useState(false);
  const [toastMessage, setToastMessage] = useState('');
  const [keyboardHeight, setKeyboardHeight] = useState(0);

  useEffect(() => {
    const handleKeyboardDidShow = (ev: any) => {
      setKeyboardHeight(ev.keyboardHeight || 0);
    };

    const handleKeyboardDidHide = () => {
      setKeyboardHeight(0);
    };

    window.addEventListener('ionKeyboardDidShow', handleKeyboardDidShow);
    window.addEventListener('ionKeyboardDidHide', handleKeyboardDidHide);

    return () => {
      window.removeEventListener('ionKeyboardDidShow', handleKeyboardDidShow);
      window.removeEventListener('ionKeyboardDidHide', handleKeyboardDidHide);
    };
  }, []);

  const showToastMessage = (message: string) => {
    setToastMessage(message);
    setShowToast(true);
  };

  const handleInitialize = async () => {
    try {
      if (!apiKey || !token || !userId || !userName || !callId) {
        showToastMessage('Please fill in all required fields');
        return;
      }

      showToastMessage('Initializing video call...');

      await StreamVideoCallCapacitor.initializeVideoCall({
        apiKey,
        token,
        preferredExtension: '',
        user: {
          id: userId,
          name: userName,
          imageURL: userImageURL || undefined,
        },
      });

      setIsInitialized(true);
      showToastMessage('Video call initialized! Joining call...');

      // Automatically join the call after initialization
      await StreamVideoCallCapacitor.joinCall({ callId });
      showToastMessage('Successfully joined the call!');
    } catch (error) {
      showToastMessage(`Failed: ${error}`);
    }
  };

  return (
    <IonApp>
      <IonPage>
        <IonHeader>
          <IonToolbar>
            <IonTitle>Stream Video Call</IonTitle>
          </IonToolbar>
        </IonHeader>

        <IonContent className="ion-padding" style={{ paddingBottom: keyboardHeight }}>
          <IonCard>
            <IonCardHeader>
              <IonCardTitle>Initialize and Join Video Call</IonCardTitle>
            </IonCardHeader>
            <IonCardContent>
              <IonItem>
                <IonLabel position="stacked">API Key *</IonLabel>
                <IonInput
                  value={apiKey}
                  placeholder="Enter your Stream API key"
                  onIonInput={(e) => setApiKey((e.target as HTMLIonInputElement).value as string)}
                />
              </IonItem>

              <IonItem>
                <IonLabel position="stacked">Token *</IonLabel>
                <IonInput
                  value={token}
                  placeholder="Enter your authentication token"
                  onIonInput={(e) => setToken((e.target as HTMLIonInputElement).value as string)}
                />
              </IonItem>

              <IonItem>
                <IonLabel position="stacked">User ID *</IonLabel>
                <IonInput
                  value={userId}
                  placeholder="Enter your user ID"
                  onIonInput={(e) => setUserId((e.target as HTMLIonInputElement).value as string)}
                />
              </IonItem>

              <IonItem>
                <IonLabel position="stacked">User Name *</IonLabel>
                <IonInput
                  value={userName}
                  placeholder="Enter your display name"
                  onIonInput={(e) => setUserName((e.target as HTMLIonInputElement).value as string)}
                />
              </IonItem>

              <IonItem>
                <IonLabel position="stacked">User Image URL (optional)</IonLabel>
                <IonInput
                  value={userImageURL}
                  placeholder="https://example.com/avatar.jpg"
                  onIonInput={(e) => setUserImageURL((e.target as HTMLIonInputElement).value as string)}
                />
              </IonItem>

              <IonItem>
                <IonLabel position="stacked">Call ID *</IonLabel>
                <IonInput
                  value={callId}
                  placeholder="Enter the call ID to join"
                  onIonInput={(e) => setCallId((e.target as HTMLIonInputElement).value as string)}
                />
              </IonItem>

              <IonButton
                expand="block"
                onClick={handleInitialize}
                color={isInitialized ? 'success' : 'primary'}
                className="ion-margin-top"
              >
                {isInitialized ? '✓ Joined Call' : 'Initialize and Join Call'}
              </IonButton>
            </IonCardContent>
          </IonCard>
          <IonToast
            isOpen={showToast}
            onDidDismiss={() => setShowToast(false)}
            message={toastMessage}
            duration={3000}
          />
        </IonContent>
      </IonPage>
    </IonApp>
  );
};

export default App;
