# Guia de Instalação e Configuração - Precinho

## 📋 Pré-requisitos

### Sistema Operacional
- Windows 10/11, macOS 10.14+, ou Linux (Ubuntu 18.04+)
- Pelo menos 8GB de RAM
- 10GB de espaço livre em disco

### Ferramentas Necessárias

1. **Flutter SDK 3.16.5+**
   - Download: https://flutter.dev/docs/get-started/install
   - Adicione o Flutter ao PATH do sistema

2. **Android Studio**
   - Download: https://developer.android.com/studio
   - Instale o Android SDK (API 21+)
   - Configure um emulador Android

3. **VS Code (Opcional)**
   - Download: https://code.visualstudio.com/
   - Instale as extensões Flutter e Dart

4. **Git**
   - Download: https://git-scm.com/

## 🚀 Instalação

### 1. Verificar Instalação do Flutter
```bash
flutter doctor
```
Certifique-se de que todos os itens estão marcados com ✓

### 2. Clonar o Projeto
```bash
git clone <url-do-repositorio>
cd precinho_app
```

### 3. Instalar Dependências
```bash
flutter pub get
```

## ⚙️ Configuração

### 1. Firebase Setup

#### 1.1. Criar Projeto Firebase
1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em "Adicionar projeto"
3. Nome do projeto: "Precinho"
4. Habilite Google Analytics (opcional)

#### 1.2. Configurar Authentication
1. No console Firebase, vá para "Authentication"
2. Clique em "Começar"
3. Na aba "Sign-in method", habilite:
   - Email/senha
   - Google (opcional)

#### 1.3. Configurar Firestore Database
1. Vá para "Firestore Database"
2. Clique em "Criar banco de dados"
3. Escolha "Iniciar no modo de teste"
4. Selecione uma localização próxima

#### 1.4. Configurar Storage
1. Vá para "Storage"
2. Clique em "Começar"
3. Aceite as regras padrão

### 2. Configuração Android

#### 2.1. Adicionar App Android
1. No console Firebase, clique no ícone Android
2. Package name: `com.precinho.precinho_app`
3. App nickname: "Precinho Android"
4. Download do arquivo `google-services.json`
5. Coloque o arquivo em `android/app/google-services.json`

#### 2.2. Configurar build.gradle
Arquivo `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

Arquivo `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 3. Configuração iOS (Opcional)

#### 3.1. Adicionar App iOS
1. No console Firebase, clique no ícone iOS
2. Bundle ID: `com.precinho.precinhoApp`
3. Download do arquivo `GoogleService-Info.plist`
4. Adicione o arquivo ao projeto iOS no Xcode

### 4. Google Maps API

#### 4.1. Obter API Key
1. Acesse [Google Cloud Console](https://console.cloud.google.com)
2. Crie um novo projeto ou selecione o existente
3. Habilite a "Maps SDK for Android" e "Maps SDK for iOS"
4. Crie uma API Key

#### 4.2. Configurar Android
Arquivo `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="SUA_API_KEY_AQUI"/>
</application>
```

#### 4.3. Configurar iOS
Arquivo `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("SUA_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 5. Permissões

#### 5.1. Android
Arquivo `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### 5.2. iOS
Arquivo `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa de acesso à localização para encontrar preços próximos.</string>
<key>NSCameraUsageDescription</key>
<string>Este app precisa de acesso à câmera para fotografar preços.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Este app precisa de acesso às fotos para selecionar imagens.</string>
```

## 🏃‍♂️ Executando a Aplicação

### 1. Verificar Dispositivos
```bash
flutter devices
```

### 2. Executar em Debug
```bash
flutter run
```

### 3. Executar em Release
```bash
flutter run --release
```

### 4. Build para Produção

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 🔧 Configurações Opcionais

### 1. Configurar Regras do Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários podem ler/escrever seus próprios dados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Produtos aprovados são públicos para leitura
    match /products/{productId} {
      allow read: if resource.data.isApproved == true;
      allow write: if request.auth != null;
    }
    
    // Preços aprovados são públicos para leitura
    match /prices/{priceId} {
      allow read: if resource.data.isApproved == true;
      allow write: if request.auth != null;
    }
    
    // Comércios aprovados são públicos para leitura
    match /stores/{storeId} {
      allow read: if resource.data.isApproved == true;
      allow write: if request.auth != null;
    }
  }
}
```

### 2. Configurar Regras do Storage
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null 
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## 🐛 Solução de Problemas

### Problema: Flutter doctor mostra erros
**Solução:** Siga as instruções específicas mostradas pelo comando

### Problema: Erro de build no Android
**Solução:** 
1. Execute `flutter clean`
2. Execute `flutter pub get`
3. Verifique se o arquivo `google-services.json` está no local correto

### Problema: Erro de permissões
**Solução:** Verifique se todas as permissões estão declaradas nos arquivos de manifesto

### Problema: Google Maps não carrega
**Solução:** 
1. Verifique se a API Key está correta
2. Certifique-se de que as APIs necessárias estão habilitadas no Google Cloud Console

## 📞 Suporte

Se encontrar problemas durante a instalação:

1. Consulte a [documentação oficial do Flutter](https://flutter.dev/docs)
2. Verifique as [issues do GitHub](link-para-issues)
3. Entre em contato: suporte@precinho.com

## ✅ Checklist de Configuração

- [ ] Flutter SDK instalado e configurado
- [ ] Android Studio instalado
- [ ] Projeto Firebase criado
- [ ] Authentication configurado
- [ ] Firestore Database criado
- [ ] Storage configurado
- [ ] Arquivo `google-services.json` adicionado
- [ ] Google Maps API configurada
- [ ] Permissões declaradas
- [ ] App executando sem erros

---

**Parabéns! Sua aplicação Precinho está pronta para uso! 🎉**

