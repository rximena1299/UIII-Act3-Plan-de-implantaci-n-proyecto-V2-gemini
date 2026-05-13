Este es el **Plan de Implementación Integral para "Apple Music Ximena"**, diseñado bajo estándares de ingeniería de software de alto nivel, con arquitectura escalable y una estética premium inspirada en el ecosistema de Apple.

---

# 🍎 Documento de Planificación Técnica: Apple Music Ximena

**Versión:** 1.0.0

**Arquitectura:** Clean Architecture + Provider

**Stack:** Flutter, Dart, Firebase

**Plataformas:** Android, Web, Windows

---

## 1. 📂 Arquitectura de Software y Estructura de Proyecto

Utilizaremos una adaptación de **Clean Architecture** para garantizar que la lógica de negocio sea independiente de la interfaz de usuario y de la base de datos (Firebase).

### Estructura de Directorios (Root: `/lib`)

```text
lib/
├── core/                        # Utilidades globales, constantes y temas
│   ├── constants/               # Colores (#FC003C), dimensiones, assets
│   ├── error/                   # Manejo de excepciones personalizadas
│   ├── theme/                   # AppTheme (Light/Dark), TextStyles (San Francisco)
│   └── utils/                   # Formateadores, validadores, helpers
├── data/                        # Implementación de datos (Infraestructura)
│   ├── datasources/             # Remote (Firebase) y Local (SharedPreferences)
│   ├── models/                  # Modelos con toFirestore() / fromFirestore()
│   └── repositories/            # Implementación real de los repositorios
├── domain/                      # Lógica de negocio (Contratos)
│   ├── entities/                # Objetos de negocio puros (Artist, Album, etc.)
│   └── repositories/            # Definición de interfaces (Abstract classes)
├── providers/                   # Gestores de estado (Capa de enlace)
│   ├── auth_provider.dart       # Sesión y seguridad
│   ├── music_provider.dart      # CRUD de artistas/álbumes
│   ├── ui_provider.dart         # Control de Sidebar, ThemeMode, Responsive Layout
│   └── stats_provider.dart      # Cálculos y analíticas para Dashboard
├── ui/                          # Capa de presentación
│   ├── animations/              # Microinteracciones y transiciones Lottie
│   ├── layouts/                 # Responsive Scaffold (Sidebar vs BottomBar)
│   ├── screens/                 # Pantallas completas por módulo
│   ├── shared/                  # Widgets reutilizables (Premium Cards, Inputs)
│   └── views/                   # Sub-vistas específicas del Dashboard
└── main.dart                    # Punto de entrada y configuración de Providers

```

---

## 2. 🧠 Gestión de Estado (Providers)

Se implementará **Provider** con un enfoque de separación de responsabilidades para optimizar los rebuilds mediante `context.select` y `Consumer`.

| Provider | Responsabilidad Principal | Flujo de Datos |
| --- | --- | --- |
| `AuthProvider` | Manejo de credenciales de administrador y persistencia de sesión. | Firebase Auth ↔ UI |
| `MusicProvider` | Operaciones CRUD para Artistas, Álbumes y Canciones. | Firestore ↔ Storage ↔ UI |
| `StatsProvider` | Cálculo de métricas en tiempo real, promedios y crecimiento. | Firestore Aggregates ↔ UI |
| `ThemeVisualProvider` | Persistencia del modo oscuro/claro y estados de la UI (Hover/Active). | Local Prefs ↔ UI |

---

## 3. 🔥 Estrategia de Backend: Firebase Ecosystem

### Estructura de Base de Datos (Cloud Firestore)

Diseño NoSQL optimizado para lectura y relaciones administrativas.

| Colección | Atributos Clave | Relaciones / Notas |
| --- | --- | --- |
| **`admins`** | `uid`, `email`, `last_login`, `name` | Datos del perfil administrativo. |
| **`artists`** | `id`, `name`, `genre_id`, `photo_url`, `bio`, `created_at` | Documento raíz para música. |
| **`albums`** | `id`, `artist_id`, `title`, `cover_url`, `year`, `track_count` | Referencia al `artist_id`. |
| **`tracks`** | `id`, `album_id`, `title`, `duration`, `file_url`, `index` | Sub-colección o colección con indexación. |
| **`playlists`** | `id`, `name`, `description`, `image_url`, `track_ids[]` | Array de referencias a `tracks`. |
| **`system_logs`** | `id`, `admin_id`, `action`, `timestamp`, `module` | Tracking de actividad (Audit trail). |

### Firebase Storage (Estructura de Archivos)

* `/artists/images/`: Fotos de perfil (compresión WebP recomendada).
* `/albums/covers/`: Portadas de discos.
* `/tracks/audio/`: Archivos .mp3 o .m4a.

---

## 4. 🎨 Diseño UI/UX: Identidad Visual Apple

### Sistema de Diseño

* **Tipografía:** Inter (o San Francisco si es posible mediante assets).
* **Componentes Premium:**
* **Glassmorphism:** Uso de `BackdropFilter` con `Sigma(10.0)` en sidebars y headers.
* **Cards:** Elevación mínima, `BorderRadius.circular(12)`, bordes sutiles de `0.5` px en gris claro/oscuro.
* **Botones:** El botón principal debe ser `#FC003C` con un gradiente lineal casi imperceptible.



### Comportamiento Responsive

* **Desktop (Windows/Web):** Sidebar fija a la izquierda (250px), contenido central en `Gridview.builder` con `SliverAppBar`.
* **Mobile (Android):** `BottomNavigationBar` con 5 iconos (Home, Search, Artists, Stats, Settings).

---

## 5. 🖥️ Módulos del Dashboard Administrativo

### A. Vista General (Analytics)

* **Header Dinámico:** Saludo personalizado según hora del día.
* **Métricas en Tiempo Real:** 4 Cards superiores con:
* Total Artistas (Icono: Music Note).
* Total Canciones (Icono: Mic).
* Crecimiento Semanal (+15%).
* Uso de Almacenamiento (Firebase Storage).


* **Gráfica de Actividad:** `fl_chart` para mostrar subida de contenido en los últimos 30 días.

### B. Gestión de Contenido (CRUD)

* **Tablas de Datos:** Uso de `PaginatedDataTable` con búsqueda integrada.
* **Modales de Carga:** Stepper interactivo para subir una canción (Paso 1: Info, Paso 2: Archivo, Paso 3: Confirmación).

---

## 6. 📦 Dependencias Críticas (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Backend & Auth
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  
  # State Management
  provider: ^6.1.1
  
  # UI & UX
  google_fonts: ^6.1.0          # Para fuente Inter/San Francisco
  flutter_spinkit: ^5.2.0       # Loaders estilo Apple
  cached_network_image: ^3.3.0  # Cache de portadas de álbumes
  fl_chart: ^0.66.0             # Gráficas profesionales
  font_awesome_flutter: ^10.6.0 # Iconografía extra
  lottie: ^3.0.0                # Animaciones en Splash y Success states
  animations: ^2.0.1            # Transiciones de página Material Motion
  
  # Utils
  shared_preferences: ^2.2.2    # Persistencia de Tema
  file_picker: ^8.0.0           # Carga de archivos en Web/Windows/Android
  intl: ^0.19.0                 # Formateo de fechas y números

```

---

## 7. 🔒 Seguridad y Reglas de Firestore

Como la app es **estrictamente administrativa**, las reglas de seguridad son cerradas:

```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // Solo usuarios autenticados pueden leer o escribir
      allow read, write: if request.auth != null;
    }
  }
}

```

*Validación adicional:* Se implementará un `AdminInterceptor` en Flutter para verificar si el UID del usuario existe en la colección `admins` antes de permitir el acceso al Dashboard.

---

## 8. 🚀 Roadmap de Desarrollo (Fases)

### Fase 1: Cimientos y Auth (Semana 1)

1. Configuración de Firebase Project (Android, Web, Windows).
2. Implementación del `ThemeData` (Red/White/Black).
3. Desarrollo de la pantalla de Login con validaciones de Regex.
4. Configuración de `AuthService` y persistencia de sesión.

### Fase 2: Arquitectura Base y Layout (Semana 2)

1. Creación del `ResponsiveLayout` (Sidebar vs BottomBar).
2. Desarrollo del Splash Screen con animación Lottie.
3. Implementación de los Repositorios base (Interfaces).

### Fase 3: CRUD de Contenido (Semana 3)

1. Módulo de Artistas: Listado, Creación y Subida de imagen a Storage.
2. Módulo de Álbumes: Vinculación con Artistas.
3. Módulo de Canciones: Subida de archivos de audio y gestión de metadatos.

### Fase 4: Dashboard y Analíticas (Semana 4)

1. Integración de `fl_chart`.
2. Cálculo de estadísticas en `StatsProvider`.
3. Vista de Actividad Reciente (Logs).

### Fase 5: Testing y Pulido (Semana 5)

1. Pruebas de estrés en subida de archivos pesados.
2. Optimización de imágenes (Caché y Lazy Loading).
3. Compilación y despliegue de versiones Alpha.

---

## 9. 🧪 Estrategia de Optimización

* **Lazy Loading:** Las listas de artistas y canciones usarán `SliverList` para renderizar solo lo que está en pantalla.
* **Image Compression:** Implementar una función en la nube (Cloud Functions opcional) o pre-procesar en Flutter para reducir el peso de los covers.
* **Shimmer Effect:** En lugar de Spinners genéricos, usar `shimmer` para mostrar esqueletos de carga de las cards de Apple Music.
