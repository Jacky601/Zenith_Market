# 🛍️ Zenith Market — Application E-Commerce avec Riverpod

**Zenith Market** est une application e-commerce mobile complète développée avec **Flutter** et le state management **Riverpod**.

Ce projet a été conçu selon les standards de l'ingénierie logicielle mobile en respectant rigoureusement le périmètre des compétences acquises (Dart moderne & POO, widgets & layouts adaptatifs, gestion des formulaires, navigation GoRouter, Riverpod 2.x/3.x et tests unitaires).

---

## 📱 Fonctionnalités Obligatoires

| Fonctionnalité | Implémentation |
| :--- | :--- |
| **Catalogue de produits** | Grille adaptative responsive (`GridView.builder` avec calcul dynamique des colonnes selon la largeur d'écran), affichage du titre, prix, catégorie, note et image. Vue détaillée complète avec sélecteur de quantité et description. |
| **Panier d'achat** | Ajout direct depuis le catalogue ou l'écran de détail, incrément / décrément de quantité, suppression d'articles, calcul dynamique du sous-total, frais de livraison offerts à partir de 50€, et dialogue de validation de commande. |
| **Système de favoris persisté** | Mise en favori réactive (icône cœur), synchronisation instantanée avec le stockage local persistant via `shared_preferences`. Les favoris restent sauvegardés même après redémarrage complet de l'application. |
| **Filtrage et tri des produits** | Recherche textuelle en temps réel (titre et description), filtrage horizontal par catégorie via des `FilterChips`, et tri avancé (en vedette, prix croissant, prix décroissant, meilleures notes). |
| **Profil utilisateur (Mock)** | Informations personnelles (nom, email, téléphone, adresse), boîte de dialogue de modification avec validation de formulaire (`Form`, `TextFormField`, validateurs regex/email), et historique des commandes passées. |

### 🎁 Bonus Implémentés
* **Animations fluides à l'ajout au panier** : Micro-animation de rebond (`ScaleTransition` avec `AnimationController`) sur le bouton d'ajout + notification Snack-bar flottante avec feedback instantané.
* **Badge réactif sur la barre de navigation** : L'icône du panier dans la barre inférieure affiche dynamiquement le nombre total d'articles présents dans le panier.
* **Résilience réseau (Fallback automatique)** : L'application interroge en priorité la FakeStore API (`https://fakestoreapi.com/products`). En cas d'absence de réseau ou d'erreur serveur, elle bascule automatiquement et de manière transparente sur un jeu de données locales de secours réalistes.

---

## 🏛️ Architecture en Couches

L'application adopte une architecture modulaire et découplée pour garantir une séparation stricte entre l'interface utilisateur, la logique métier et la couche de données :

```text
lib/
├── core/
│   ├── router/
│   │   └── app_router.dart              # Configuration GoRouter + StatefulShellRoute (onglets)
│   ├── theme/
│   │   └── app_theme.dart               # Thème moderne Material 3 et palette de couleurs
│   └── utils/
│       └── formatters.dart              # Helpers de formatage (devises €, dates)
├── data/
│   ├── local/
│   │   └── favorites_storage.dart       # Persistance SharedPreferences pour les favoris
│   ├── models/
│   │   ├── product.dart                 # Modèle Produit avec sérialisation JSON robuste
│   │   ├── cart_item.dart               # Modèle Article Panier avec sous-totaux
│   │   ├── sort_option.dart             # Enumération des options de tri
│   │   └── user_profile.dart            # Modèle Utilisateur et Commandes
│   └── repositories/
│       ├── product_repository.dart      # Gestion des requêtes API REST + fallback hors-ligne
│       └── mock_products_data.dart      # Données de secours locales complètes
├── providers/
│   ├── products_provider.dart           # productsFutureProvider & filteredProductsProvider
│   ├── filter_providers.dart            # search, category et sort Notifiers
│   ├── cart_provider.dart               # CartNotifier & cartNotifierProvider
│   ├── favorites_provider.dart          # FavoritesNotifier (AsyncNotifier) & favoris dérivés
│   └── profile_provider.dart            # userProfileProvider
└── presentation/
    ├── screens/
    │   ├── main_scaffold_screen.dart    # Shell principal avec NavigationBar et badge panier
    │   ├── catalog_screen.dart          # Catalogue, recherche, chips et grille responsive
    │   ├── product_detail_screen.dart   # Page détaillée avec Hero, quantité et ajout panier
    │   ├── cart_screen.dart             # Panier complet avec récapitulatif financier
    │   ├── favorites_screen.dart        # Écran des favoris synchronisés
    │   └── profile_screen.dart          # Profil utilisateur, formulaires et historique
    └── widgets/
        ├── product_card.dart            # Carte produit animée et interactive
        ├── cart_item_tile.dart          # Tuile d'article de panier avec contrôles +/-
        ├── category_chips.dart          # Sélecteur horizontal de catégories
        ├── search_and_sort_bar.dart     # Barre de recherche et menu popup de tri
        ├── empty_state_view.dart        # Vue d'état vide réutilisable
        └── error_state_view.dart        # Vue de gestion d'erreur avec bouton 'Réessayer'
```

---

## ⚡ Détail des Providers Riverpod Utilisés

Le projet utilise **10 providers distincts** illustrant les concepts clés de Riverpod (chargement asynchrone, modificateurs, providers dérivés et state notifiers) :

| Provider | Type | Rôle & Utilité |
| :--- | :--- | :--- |
| `productRepositoryProvider` | `Provider<ProductRepository>` | Fournit l'instance du repository pour les appels de données. |
| `productsFutureProvider` | `FutureProvider<List<Product>>` | Charge asynchronement la liste des produits depuis l'API ou le fallback local. Expose un état `AsyncValue`. |
| `availableCategoriesProvider` | `Provider<List<String>>` | Provider dérivé extrayant dynamiquement les catégories uniques des produits chargés. |
| `searchQueryProvider` | `NotifierProvider<SearchQueryNotifier, String>` | Gère l'état réactif du texte saisi dans la barre de recherche. |
| `selectedCategoryProvider` | `NotifierProvider<SelectedCategoryNotifier, String?>` | Maintient la catégorie actuellement sélectionnée (`null` = tous). |
| `sortByProvider` | `NotifierProvider<SortByNotifier, SortOption>` | Maintient le mode de tri actif (croissant, décroissant, notation...). |
| `filteredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Provider dérivé combinant la liste brute avec la recherche, la catégorie et le tri en conservant l'état `AsyncValue`. |
| `productByIdProvider` | `Provider.family<Product?, String>` | Provider avec modificateur `family` pour retrouver instantanément un produit par son ID. |
| `cartNotifierProvider` | `NotifierProvider<CartNotifier, CartState>` | Gère l'état immuable du panier (articles, quantités, sous-total, livraison, total, actions add/remove/clear). |
| `favoritesNotifierProvider` | `AsyncNotifierProvider<FavoritesNotifier, Set<String>>` | Gère les IDs favoris avec chargement et sauvegarde asynchrone dans `shared_preferences`. |
| `favoriteProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Provider dérivé exposant les objets `Product` complets favoris pour l'écran dédié. |
| `userProfileProvider` | `NotifierProvider<ProfileNotifier, UserProfile>` | Gère les données mockées du profil utilisateur et permet leur mise à jour. |

---

## 🧪 Tests Automatisés

Le projet intègre une suite de tests unitaires et de widgets :
- **`test/cart_test.dart`** : Vérification du cycle de vie du panier (démarrage à vide, ajout, calcul des frais offerts >= 50€, incrément/décrément, vidage).
- **`test/products_test.dart`** : Test de désérialisation JSON (`Product.fromJson`), valeurs par défaut en cas de champs manquants et méthode `copyWith`.
- **`test/widget_test.dart`** : Test d'intégration de base montant `ZenithMarketApp` avec `ProviderScope`.

Pour exécuter les tests :
```bash
flutter test
```

Pour exécuter l'analyse statique :
```bash
flutter analyze
```

---

## 🚀 Lancement du Projet

1. Cloner le dépôt Git :
```bash
git clone <URL_DU_DEPOT>
cd Projet_Flutter_2
```

2. Récupérer les dépendances :
```bash
flutter pub get
```

3. Lancer l'application :
```bash
# Sur Chrome / Web
flutter run -d chrome

# Ou sur Linux Desktop
flutter run -d linux
```

---
