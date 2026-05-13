

# 🎵 APPLE MUSIC XIMENA: PLAN DE IMPLEMENTACIÓN FINAL

**Documentación de Ingeniería y Diseño - Versión 2.0 (Empresarial)**

---

## 1. 📂 ARQUITECTURA Y ESTRUCTURA DE ARCHIVOS

El proyecto utiliza una arquitectura **Modular por Capas (Clean Architecture)** adaptada para **Provider**. Esto separa la lógica de Firebase de la interfaz de usuario.

### Árbol de Directorios Detallado

```text
lib/
├── core/
│   ├── constants/            # Colores (#FC003C), strings, tamaños y assets.
│   ├── theme/                # Definición de ThemeData (Dark/Light) y extensiones.
│   ├── routes/               # Manejo de rutas y guardias de seguridad (Admin only).
│   └── utils/                # Formateadores (minutos/segundos) y validadores.
├── data/                     # INFRAESTRUCTURA
│   ├── models/               # Modelos con serialización JSON/Firestore.
│   ├── repositories/         # Implementación de los contratos (Llamadas a Firebase).
│   └── services/             # Servicios directos (AuthService, CloudStorageService).
├── domain/                   # Lógica de negocio pura (Contratos y Entidades).
├── providers/                # GESTIÓN DE ESTADO (Capa de enlace)
│   ├── auth_provider.dart    # Sesión y protección de rutas.
│   ├── music_provider.dart   # Lógica CRUD de artistas, álbumes y canciones.
│   ├── dashboard_provider.dart # Cálculo de métricas y gráficas.
│   └── ui_provider.dart      # Control de Sidebar, ThemeMode y Responsividad.
├── ui/                       # PRESENTACIÓN (Diseño Apple)
│   ├── layouts/              # Scaffolds responsivos (Web/Windows vs Android).
│   ├── screens/              # Pantallas principales (Dashboard, Login, Artistas).
│   ├── shared/               # Widgets premium (AppleButton, AppleTextField).
│   └── animations/           # Transiciones Lottie y Micro-animaciones.
└── main.dart                 # Inicialización y MultiProvider.

```

---

## 2. 🎨 SISTEMA DE DISEÑO (IDENTITY & UI)

La interfaz es una recreación fiel del ecosistema de Apple, priorizando la elegancia y la limpieza visual.

### Paleta de Colores Oficial

| Variable | Hexadecimal | Uso |
| --- | --- | --- |
| **Primary Red** | `#FC003C` | Botones de acción, estados activos, iconos de marca. |
| **Pure White** | `#FFFFFF` | Fondos en modo claro, texto en modo oscuro. |
| **Dark Background** | `#0D0D0D` | Fondo principal profundo (OLED Black). |
| **Surface Dark** | `#1C1C1E` | Fondo de Cards, Sidebars y Modales en Dark Mode. |
| **System Grey** | `#8E8E93` | Textos secundarios y descripciones. |

### Componentes Visuales Clave

* **Glassmorphism:** Uso de `BackdropFilter` con `sigma(10.0)` en la barra lateral (Web) y barra de navegación (Android).
* **Tipografía:** Inter o San Francisco, utilizando una jerarquía de pesos fuerte (Bold para títulos, Regular para datos).
* **Botones:** Bordes redondeados (`12.0`), sombreado suave y efectos de escala (0.95) al presionar.

---

## 3. 🧠 FUNCIONALIDADES ADMINISTRATIVAS (Lógica de Negocio)

Como aplicación puramente administrativa, el sistema se enfoca en la gestión de datos masivos.

* **Dashboard Inteligente:** Visualización de métricas reales (Total de archivos almacenados, crecimiento de artistas).
* **Sistema de Ingesta:** Subida de archivos de audio (.mp3, .m4a) y portadas con barras de progreso en tiempo real.
* **Gestión de Relaciones:** Al crear un álbum, se vincula automáticamente al ID del artista; al crear una canción, se hereda la metadata del álbum.
* **Logs de Auditoría:** Registro automático de quién (admin) hizo qué cambio y en qué momento.

---

## 4. 🔥 FIREBASE ECOSISTEMA (Backend)

Configuración de la base de datos NoSQL y almacenamiento.

### Estructura de Colecciones (Firestore)

* **`administrators/`**: `{ uid, name, email, lastLogin }`
* **`artists/`**: `{ id, name, bio, photoUrl, genre }`
* **`albums/`**: `{ id, artistId, title, coverUrl, year, trackCount }`
* **`tracks/`**: `{ id, albumId, artistId, title, audioUrl, duration }`
* **`system_stats/`**: `{ totalSongs, totalArtists, storageUsed }` (Actualizado vía Cloud Functions o transacciones).

### Almacenamiento (Storage)

* Estructura: `/music/{artist_id}/{album_id}/{track_file}`.
* Estructura: `/images/{artist_id}/profile.jpg`.

---

## 5. 📦 DEPENDENCIAS CRÍTICAS (`pubspec.yaml`)

Organizadas por su propósito en el proyecto:

* **Backend:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.
* **Estado:** `provider`.
* **Diseño:** `google_fonts`, `cached_network_image` (Caché de portadas), `flutter_spinkit` (Loaders Apple).
* **Gráficas:** `fl_chart` (Gráficas de líneas y barras para el Dashboard).
* **Interacción:** `lottie` (Animaciones de éxito), `file_picker` (Subida de música), `animations` (Transiciones entre pantallas).
* **Persistencia:** `shared_preferences` (Modo oscuro).

---

## 6. 📱 RESPONSIVIDAD (Adaptive Layouts)

El sistema cambia drásticamente según la plataforma para mantenerse ergonómico.

| Plataforma | Navegación | Visualización de Datos |
| --- | --- | --- |
| **Android** | `BottomNavigationBar` (Iconos minimalistas). | Cards verticales, listas de un solo carril. |
| **Web/Windows** | `Sidebar` fija a la izquierda (Efecto Glass). | Grid de 3 a 5 columnas, tablas extendidas. |

---

## 7. 🔒 SEGURIDAD Y OPTIMIZACIÓN

* **Seguridad:** Reglas de Firestore que impiden el acceso a cualquier usuario que no esté autenticado con un correo institucional.
* **Rendimiento:** * **Lazy Loading:** Las listas de música solo cargan 20 elementos a la vez.
* **Image Optimization:** Las fotos se procesan para no exceder los 500kb antes de subir al Storage.
* **Provider Selectors:** Solo se reconstruyen los widgets pequeños cuando cambia un dato, no toda la pantalla.



---

## 8. ✅ CHECKLIST DE FUNCIONES POR MÓDULO

### **Módulo Auth**

* [ ] Pantalla de Login estética Apple.
* [ ] Recuperación de contraseña vía Email.
* [ ] Persistencia de sesión (Auto-login).

### **Módulo Dashboard**

* [ ] Gráfica de actividad semanal.
* [ ] Conteo en tiempo real de la base de datos.
* [ ] Notificaciones de errores de servidor.

### **Módulo CRUD (Música)**

* [ ] Buscador de artistas con sugerencias.
* [ ] Editor de metadatos de canciones.
* [ ] Selector de archivos múltiples para álbumes.

### **Módulo Configuración**

* [ ] Switch de Modo Oscuro/Claro.
* [ ] Edición de perfil de administrador.
* [ ] Botón de cierre de sesión seguro.
