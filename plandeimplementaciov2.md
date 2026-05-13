# Plan de Implementación — Apple Music Ximena

## Descripción General del Proyecto

Apple Music Ximena será una aplicación multiplataforma desarrollada con Flutter y Dart enfocada en la administración y reproducción musical inspirada visual y funcionalmente en Apple Music. El sistema permitirá gestionar artistas, canciones, playlists, usuarios y reproducción musical mediante una arquitectura profesional basada en Firebase y Provider.

La aplicación estará diseñada para Android, Web y Windows, utilizando una estructura escalable, modular y responsive que facilite el mantenimiento, la expansión de funcionalidades y la integración de nuevos módulos en futuras versiones.

El objetivo principal del proyecto es desarrollar una plataforma moderna y elegante con autenticación segura, panel administrativo, CRUD completo de artistas y reproducción musical en tiempo real.

---

# Objetivos del Sistema

El sistema tendrá como finalidad:

* Reproducir música
* Gestionar playlists
* Administrar artistas
* Administrar usuarios
* Permitir autenticación segura
* Integrar Firebase Firestore
* Almacenar imágenes en Firebase Storage
* Implementar panel administrativo
* Gestionar favoritos
* Soportar múltiples plataformas

---

# Tecnologías Utilizadas

| Tecnología           | Función                    |
| -------------------- | -------------------------- |
| Flutter              | Framework principal        |
| Dart                 | Lenguaje de programación   |
| Firebase Auth        | Autenticación              |
| Cloud Firestore      | Base de datos              |
| Firebase Storage     | Almacenamiento de imágenes |
| Provider             | Gestión de estado          |
| Just Audio           | Reproductor musical        |
| Go Router            | Navegación                 |
| Shared Preferences   | Persistencia local         |
| Google Fonts         | Tipografías                |
| Cached Network Image | Caché de imágenes          |
| Lottie               | Animaciones                |

---

# Arquitectura General del Proyecto

La arquitectura del proyecto seguirá el patrón:

```plaintext
UI
 ↓
Provider
 ↓
Repository
 ↓
Firebase Services
 ↓
Firestore / Storage / Auth
```

Esta estructura permitirá:

* Separación de responsabilidades
* Escalabilidad
* Fácil mantenimiento
* Reutilización de código
* Modularidad
* Mejor testing

---

# Estructura General de Carpetas

```plaintext
apple_music_ximena/
│
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── audio/
│
├── lib/
│   ├── core/
│   ├── models/
│   ├── providers/
│   ├── repositories/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   ├── routes/
│   ├── theme/
│   └── utils/
│
├── pubspec.yaml
└── README.md
```

---

# Estructura Completa del Directorio lib

```plaintext
lib/
│
├── main.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   ├── app_strings.dart
│   │   └── firebase_constants.dart
│   │
│   ├── routes/
│   │   └── app_routes.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   │
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── storage_service.dart
│   │   └── audio_service.dart
│   │
│   └── utils/
│       ├── validators.dart
│       ├── helpers.dart
│       └── date_formatter.dart
│
├── models/
│   ├── usuario_model.dart
│   ├── artista_model.dart
│   ├── album_model.dart
│   ├── cancion_model.dart
│   ├── playlist_model.dart
│   └── suscripcion_model.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── artista_provider.dart
│   ├── music_provider.dart
│   ├── playlist_provider.dart
│   ├── loading_provider.dart
│   └── theme_provider.dart
│
├── repositories/
│   ├── auth_repository.dart
│   ├── artista_repository.dart
│   ├── music_repository.dart
│   └── playlist_repository.dart
│
├── screens/
│   ├── splash/
│   ├── auth/
│   ├── home/
│   ├── artistas/
│   ├── playlists/
│   ├── reproductor/
│   ├── perfil/
│   └── admin/
│
├── widgets/
│   ├── custom_button.dart
│   ├── custom_textfield.dart
│   ├── custom_drawer.dart
│   ├── custom_appbar.dart
│   ├── loading_widget.dart
│   └── music_card.dart
│
└── firebase_options.dart
```

---

# Diseño Visual del Sistema

La interfaz seguirá una línea visual premium inspirada en Apple Music.

Características visuales:

* Estilo minimalista
* Interfaz oscura elegante
* Elementos translúcidos
* Sombras suaves
* Cards modernas
* Bordes redondeados
* Diseño responsive
* Transiciones suaves
* Animaciones Lottie

---

# Paleta Oficial de Colores

| Elemento         | Color   |
| ---------------- | ------- |
| Fondo principal  | #0F0F0F |
| Fondo secundario | #1C1C1E |
| Rosa principal   | #FF2D55 |
| Rosa secundario  | #FF5C8A |
| Blanco           | #FFFFFF |
| Gris texto       | #B3B3B3 |
| Verde éxito      | #30D158 |
| Rojo error       | #FF453A |

---

# Tipografía

La aplicación utilizará:

* SF Pro Display
* Poppins

Tamaños definidos:

| Uso              | Tamaño |
| ---------------- | ------ |
| Título principal | 28     |
| Subtítulo        | 22     |
| Texto normal     | 16     |
| Botones          | 18     |

---

# Sistema de Autenticación

El sistema de autenticación incluirá:

## Login

* Inicio de sesión con email
* Inicio de sesión con Google
* Recuperación de contraseña
* Validaciones
* Manejo de errores

## Registro

* Nombre
* Email
* Contraseña
* Confirmar contraseña

## Forgot Password

* Recuperación vía correo electrónico

---

# Firebase

El proyecto utilizará Firebase como backend principal.

## Servicios Firebase

* Firebase Authentication
* Cloud Firestore
* Firebase Storage

## Colecciones Firestore

### usuarios

```plaintext
usuarios/
   uid/
      nombre
      email
      foto
      fechaRegistro
```

### artistas

```plaintext
artistas/
   artistaId/
      nombreArtistico
      nombreReal
      paisOrigen
      biografia
      imagenUrl
```

### playlists

```plaintext
playlists/
   playlistId/
      nombre
      descripcion
      usuarioId
```

### canciones

```plaintext
canciones/
   cancionId/
      titulo
      artista
      album
      duracion
```

---

# Entidades del Sistema

## Entidades principales

1. Usuario
2. Suscripción
3. Artista
4. Album
5. Canción
6. Playlist
7. Playlist_Cancion
8. Reproducción
9. Genero_Musical
10. Dispositivo

---

# Relaciones de Base de Datos

```plaintext
USUARIO → PLAYLIST
USUARIO → REPRODUCCION
ARTISTA → ALBUM
ALBUM → CANCION
PLAYLIST ↔ CANCION
```

---

# Providers del Sistema

## AuthProvider

Responsable de:

* login()
* register()
* logout()
* loginWithGoogle()
* resetPassword()

---

## ArtistaProvider

Responsable de:

* agregarArtista()
* listarArtistas()
* editarArtista()
* eliminarArtista()

---

## MusicProvider

Responsable de:

* playMusic()
* pauseMusic()
* nextMusic()
* previousMusic()

---

## PlaylistProvider

Responsable de:

* crearPlaylist()
* eliminarPlaylist()
* agregarCancion()

---

# CRUD de Artistas

El sistema permitirá operaciones completas sobre artistas.

## Funciones CRUD

| Acción     | Función           |
| ---------- | ----------------- |
| Crear      | agregarArtista()  |
| Leer       | listarArtistas()  |
| Actualizar | editarArtista()   |
| Eliminar   | eliminarArtista() |

---

# Campos del Artista

```plaintext
nombreArtistico
nombreReal
paisOrigen
biografia
imagenUrl
```

---

# Navegación del Sistema

## BottomNavigationBar

La navegación principal incluirá:

1. Inicio
2. Música
3. Playlists
4. Artistas
5. Perfil

---

# Reproductor Musical

## Funciones del reproductor

* Play
* Pause
* Repeat
* Shuffle
* Barra de progreso
* Mini player
* Cola de reproducción
* Control de volumen

---

# Panel Administrativo

El dashboard administrativo mostrará:

* Usuarios registrados
* Total artistas
* Total canciones
* Total playlists
* Estadísticas generales
* Actividad reciente

---

# Responsive Design

## Android

* BottomNavigationBar
* Diseño móvil optimizado

## Web

* Sidebar lateral
* Layout expandido

## Windows

* Dashboard amplio
* Paneles administrativos

---

# Seguridad Firestore

## Reglas principales

```plaintext
Solo usuarios autenticados podrán acceder a la base de datos.

Los administradores tendrán permisos para modificar artistas.
```

---

# Tema Oscuro

Características:

* Fondo negro premium
* Transparencias
* Efectos blur
* Cards elevadas
* Sombras suaves

---

# Dependencias pubspec.yaml
```dart id="s5v1ml"
class AppDependencies {
  static const String firebaseCore = 'firebase_core: ^3.13.0';
  static const String firebaseAuth = 'firebase_auth: ^5.5.0';
  static const String cloudFirestore = 'cloud_firestore: ^5.6.4';
  static const String firebaseStorage = 'firebase_storage: ^12.4.4';

  static const String googleSignIn = 'google_sign_in: ^6.2.2';

  static const String provider = 'provider: ^6.1.2';

  static const String goRouter = 'go_router: ^14.8.1';

  static const String sharedPreferences =
      'shared_preferences: ^2.5.2';

  static const String googleFonts =
      'google_fonts: ^6.2.1';

  static const String cachedNetworkImage =
      'cached_network_image: ^3.4.1';

  static const String imagePicker =
      'image_picker: ^1.1.2';

  static const String lottie =
      'lottie: ^3.3.1';

  static const String justAudio =
      'just_audio: ^0.9.46';

  static const String audioService =
      'audio_service: ^0.18.17';

  static const String intl =
      'intl: ^0.20.2';

  static const String uuid =
      'uuid: ^4.5.1';
}
```



---

# Fases de Desarrollo

| Fase | Implementación         |
| ---- | ---------------------- |
| 1    | Configuración Flutter  |
| 2    | Configuración Firebase |
| 3    | Sistema Login          |
| 4    | Providers              |
| 5    | CRUD Artistas          |
| 6    | Playlists              |
| 7    | Reproductor Musical    |
| 8    | Dashboard              |
| 9    | Responsive Design      |
| 10   | Testing                |

---

# Testing

## Tipos de pruebas

* Unit Test
* Widget Test
* Integration Test

---

# Objetivo Final del Proyecto

Desarrollar una aplicación multiplataforma moderna y profesional inspirada en Apple Music utilizando Flutter, Firebase y Provider, implementando arquitectura escalable, autenticación segura, reproducción musical y administración completa de contenido musical mediante una interfaz elegante, responsive y optimizada para múltiples dispositivos.
