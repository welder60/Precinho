# Guia para Testar a Versão Web - Precinho

## 🌐 Configuração para Web

A aplicação Precinho foi configurada para funcionar na web com as seguintes adaptações:

### ✅ Configurações Implementadas:
- **Flutter Web habilitado**
- **Firebase Web configurado**
- **Interface responsiva** (NavigationRail para desktop)
- **Funcionalidades adaptadas** para web
- **Configuração de CORS** para Firebase

## 🚀 Como Executar a Versão Web

### 1. Pré-requisitos
```bash
# Verificar se Flutter está instalado
flutter --version

# Habilitar suporte web (se não estiver habilitado)
flutter config --enable-web

# Verificar dispositivos disponíveis
flutter devices
```

### 2. Configurar Firebase para Web

#### 2.1. No Firebase Console:
1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto
3. Clique no ícone **Web** (</>) para adicionar app web
4. Registre o app com nome "Precinho Web"
5. Copie a configuração Firebase

#### 2.2. Gerar `firebase_options.dart`:
Utilize o FlutterFire CLI para criar automaticamente o arquivo com as chaves do seu projeto:

```bash
flutterfire configure
```

O comando acima gera `lib/firebase_options.dart` e você poderá inicializar o Firebase com `DefaultFirebaseOptions.currentPlatform`.

#### 2.3. Atualizar `web/index.html`:
Se preferir configurar manualmente, substitua os valores de exemplo presentes em `web/index.html` (API key, authDomain, etc.) pelos dados copiados do Firebase Console.

### 3. Executar a Aplicação

#### 3.1. Instalar Dependências:
```bash
cd precinho_app
flutter pub get
```

#### 3.2. Executar em Modo Debug:
```bash
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

#### 3.3. Build para Produção:
```bash
flutter build web --release
```

### 4. Acessar a Aplicação

Após executar, a aplicação estará disponível em:
- **Local**: http://localhost:8080
- **Rede**: http://SEU_IP:8080

## 🎯 Funcionalidades Disponíveis na Web

### ✅ Funcionais:
- **Autenticação** (Email/Senha e Google)
- **Interface responsiva** com NavigationRail
- **Telas principais** (Mapa, Busca, Listas, Perfil)
- **Gerenciamento de estado** com Riverpod
- **Tema Material Design 3**

### ⚠️ Limitadas na Web:
- **Câmera** (não disponível em navegadores desktop)
- **Geolocalização** (requer permissão do navegador)
- **Notificações push** (limitadas no navegador)

### 🔧 Adaptações para Web:
- **NavigationRail** em vez de BottomNavigationBar
- **Funcionalidades de câmera** desabilitadas
- **Layout responsivo** para diferentes tamanhos de tela

## 🛠️ Solução de Problemas

### Problema: Erro de CORS
**Solução:**
```bash
# Executar com CORS desabilitado (apenas para desenvolvimento)
flutter run -d web-server --web-browser-flag="--disable-web-security"
```

### Problema: Firebase não conecta
**Solução:**
1. Verificar se as configurações Firebase estão corretas
2. Habilitar domínio autorizado no Firebase Console
3. Verificar se Authentication está habilitado

### Problema: Geolocalização não funciona
**Solução:**
1. Usar HTTPS (obrigatório para geolocalização)
2. Permitir localização no navegador
3. Testar em navegador compatível (Chrome, Firefox)

### Problema: Google Sign-In não funciona
**Solução:**
1. Configurar domínio autorizado no Google Console
2. Adicionar JavaScript origins no Google Cloud Console
3. Verificar se as credenciais estão corretas

## 🌐 Deploy para Produção

### 1. Build de Produção:
```bash
flutter build web --release
```

### 2. Arquivos Gerados:
Os arquivos estarão em `build/web/`

### 3. Hospedagem Sugerida:
- **Firebase Hosting** (recomendado)
- **Netlify**
- **Vercel**
- **GitHub Pages**

### 4. Deploy no Firebase Hosting:
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login no Firebase
firebase login

# Inicializar projeto
firebase init hosting

# Deploy
firebase deploy
```

## 📱 Teste em Diferentes Dispositivos

### Desktop:
- **Chrome** (recomendado)
- **Firefox**
- **Safari**
- **Edge**

### Mobile (via navegador):
- **Chrome Mobile**
- **Safari Mobile**
- **Firefox Mobile**

### Responsividade:
- **Desktop**: NavigationRail lateral
- **Tablet**: NavigationRail ou BottomNavigation
- **Mobile**: BottomNavigationBar

## 🔍 Funcionalidades de Teste

### 1. Autenticação:
- [ ] Login com email/senha
- [ ] Cadastro de novo usuário
- [ ] Login com Google
- [ ] Logout

### 2. Navegação:
- [ ] Mapa de preços
- [ ] Busca de produtos
- [ ] Listas de compras
- [ ] Perfil do usuário

### 3. Interface:
- [ ] Tema Material Design 3
- [ ] Responsividade
- [ ] NavigationRail (desktop)
- [ ] BottomNavigation (mobile)

### 4. Estado:
- [ ] Gerenciamento com Riverpod
- [ ] Persistência de login
- [ ] Carregamento de dados

## 📋 Checklist de Configuração

- [ ] Flutter Web habilitado
- [ ] Firebase projeto criado
- [ ] Firebase Web app configurado
- [ ] Configurações Firebase atualizadas
- [ ] Dependências instaladas
- [ ] Aplicação executando localmente
- [ ] Autenticação funcionando
- [ ] Interface responsiva
- [ ] Testes em diferentes navegadores

## 🆘 Suporte

Se encontrar problemas:

1. **Verificar logs do console** do navegador (F12)
2. **Verificar logs do Flutter** no terminal
3. **Consultar documentação** do Firebase Web
4. **Testar em modo incógnito** para evitar cache

---

**A aplicação Precinho está pronta para teste na web! 🎉**

