import React, { Suspense } from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import { IonApp, setupIonicReact } from '@ionic/react';
import { IonReactRouter } from '@ionic/react-router';

/**
 * Setting for disabling back gesture for iOS
 */
setupIonicReact({
  swipeBackEnabled: false,
});

/**
 * Render an App component in the root
 */
ReactDOM.render(
  <IonApp>
    <Suspense fallback={''}>
      <IonReactRouter>
        <App />
      </IonReactRouter>
    </Suspense>
  </IonApp>,
  document.getElementById('root')
);
