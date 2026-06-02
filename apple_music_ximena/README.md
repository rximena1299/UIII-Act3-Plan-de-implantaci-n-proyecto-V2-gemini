# Apple Music Ximena 🎵

Una réplica interactiva y premium de Apple Music desarrollada con Flutter, diseñada para ofrecer una experiencia visual y auditiva de alta calidad.

Este proyecto ha sido optimizado y configurado para ejecutarse tanto en **Android** como en la **Web**.

---

## 🚀 Modos de Ejecución

La aplicación cuenta con un sistema inteligente de detección de servicios. Si Firebase no está configurado o falla al inicializarse en la plataforma actual:
1. **Modo Firebase (Online):** Si las credenciales y configuraciones están completas, la aplicación sincroniza la música, playlists y perfiles con Firestore en tiempo real.
2. **Modo Local (Mock/Offline):** Si Firebase no está disponible, la app entra automáticamente en un modo Mock con datos locales precargados de alta calidad para asegurar que la navegación, reproducción y funcionalidades sigan operativas sin interrupción.

---

## 💻 Ejecución en la Web

### 1. Iniciar Servidor de Desarrollo
Para correr el proyecto en modo desarrollo usando Google Chrome, navega a la carpeta del proyecto y ejecuta:
```bash
cd apple_music_ximena
flutter run -d chrome
```

### 2. Compilar para Producción
Para compilar la versión optimizada para web:
```bash
flutter build web
```
Los archivos de distribución se generarán en la carpeta `build/web/` listos para ser desplegados en cualquier servidor web (como GitHub Pages, Vercel, Firebase Hosting, etc.).

---

## 📱 Ejecución en Android

### 1. Iniciar en un Emulador o Dispositivo Físico
Asegúrate de tener un dispositivo conectado o emulador activo y ejecuta:
```bash
flutter run
```

### 2. Compilar APK de Lanzamiento (Release)
Para generar un APK optimizado y listo para instalar:
```bash
flutter build apk --release
```
El archivo se generará en `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🛠️ Configuración de Firebase para Web

Las configuraciones de Firebase en `lib/firebase_options.dart` han sido actualizadas para apuntar al proyecto `proyectofinal-4d22d`.

Si deseas conectar la versión Web a la base de datos real de Firebase, sigue estos pasos:
1. Ve a tu **Firebase Console**.
2. Agrega una nueva **Aplicación Web** a tu proyecto `proyectofinal-4d22d`.
3. Copia el `appId` que te genere Firebase (formato `1:83515133518:web:xxxxxx`).
4. Reemplaza el valor dummy en [firebase_options.dart](file:///c:/Users/Andrea/Downloads/UIII-Act3-Plan-de-implantaci-n-proyecto-V2-gemini-main/UIII-Act3-Plan-de-implantaci-n-proyecto-V2-gemini-main/apple_music_ximena/lib/firebase_options.dart):
   ```dart
   appId: '1:83515133518:web:TU_APP_ID_AQUÍ'
   ```
