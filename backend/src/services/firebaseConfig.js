import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyCdRNTr7bDWA8_JMD1j9bEIdIVREwn33kU",
  authDomain: "pi-3--mescla-invest.firebaseapp.com",
  projectId: "pi-3--mescla-invest",
  storageBucket: "pi-3--mescla-invest.firebasestorage.app",
  messagingSenderId: "696645311566",
  appId: "1:696645311566:web:262642b6ec4224f562771f",
  measurementId: "G-B5W3JSPEYB"
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);