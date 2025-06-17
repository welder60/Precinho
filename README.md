# Precinho - Aplicativo de Compartilhamento de Preços

## 📱 Sobre o Aplicativo

O **Precinho** é um aplicativo mobile desenvolvido em Flutter que permite aos usuários compartilhar e consultar preços de produtos de supermercado de forma colaborativa. O objetivo é ajudar os consumidores a encontrar os melhores preços próximos à sua localização.

## ✨ Funcionalidades Principais

### 🔐 Autenticação
- Login com email/senha
- Cadastro de novos usuários
- Login social com Google
- Recuperação de senha

### 🗺️ Mapa de Preços
- Visualização de preços em mapa interativo
- Busca por raio geográfico
- Filtros por categoria e estabelecimento
- Localização automática do usuário

### 🔍 Busca de Produtos
- Busca por nome do produto
- Filtros por categoria
- Ordenação por preço e distância
- Comparação de preços entre estabelecimentos

### 📝 Cadastro de Preços
- Captura de foto do preço
- Inserção manual de dados
- Escaneamento de nota fiscal (OCR)
- Validação por moderação

### 🛒 Listas de Compras
- Criação de múltiplas listas
- Cálculo de valor total por estabelecimento
- Sugestão de melhor combinação de lojas
- Acompanhamento de progresso

### 🏆 Gamificação
- Sistema de pontuação
- Ranking de colaboradores
- Badges e conquistas
- Histórico de contribuições

### 👤 Perfil do Usuário
- Estatísticas pessoais
- Histórico de atividades
- Configurações de privacidade
- Gerenciamento de conta

## 🏗️ Arquitetura

### Padrão Arquitetural
- **MVVM (Model-View-ViewModel)** com Provider/Riverpod
- **Clean Architecture** com separação em camadas:
  - **Presentation Layer**: UI e gerenciamento de estado
  - **Domain Layer**: Lógica de negócio e entidades
  - **Data Layer**: Repositórios e fontes de dados

### Estrutura de Pastas
```
lib/
├── core/                    # Núcleo da aplicação
│   ├── constants/          # Constantes e enums
│   ├── errors/             # Classes de erro
│   ├── utils/              # Utilitários e validadores
│   └── themes/             # Temas e estilos
├── data/                   # Camada de dados
│   ├── datasources/        # Fontes de dados (API, local)
│   ├── models/             # Modelos de dados
│   └── repositories/       # Implementação de repositórios
├── domain/                 # Camada de domínio
│   ├── entities/           # Entidades de negócio
│   ├── repositories/       # Contratos de repositórios
│   └── usecases/           # Casos de uso
└── presentation/           # Camada de apresentação
    ├── pages/              # Telas da aplicação
    ├── widgets/            # Widgets reutilizáveis
    └── providers/          # Gerenciamento de estado
```

## 🛠️ Tecnologias Utilizadas

### Framework e Linguagem
- **Flutter 3.16.5**
- **Dart 3.2.3**

### Gerenciamento de Estado
- **Riverpod 2.4.9** - Gerenciamento de estado reativo
- **Provider 6.1.1** - Alternativa para casos simples

### Backend e Banco de Dados
- **Firebase Core 2.24.2** - Plataforma backend
- **Cloud Firestore 4.13.6** - Banco de dados NoSQL
- **Firebase Auth 4.15.3** - Autenticação
- **Firebase Storage 11.5.6** - Armazenamento de imagens

### Geolocalização e Mapas
- **Geolocator 10.1.0** - Serviços de localização
- **Geocoding 2.1.1** - Conversão de coordenadas
- **Google Maps Flutter 2.5.0** - Mapas interativos

### Câmera e Imagens
- **Camera 0.10.5+5** - Acesso à câmera
- **Image Picker 1.0.4** - Seleção de imagens
- **Google ML Kit Text Recognition 0.10.0** - OCR para notas fiscais

### Networking
- **Dio 5.3.2** - Cliente HTTP avançado
- **HTTP 1.1.0** - Requisições HTTP básicas

### Utilitários
- **Intl 0.18.1** - Internacionalização
- **UUID 4.2.1** - Geração de identificadores únicos
- **Cached Network Image 3.3.0** - Cache de imagens
- **Permission Handler 11.1.0** - Gerenciamento de permissões

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.16.5 ou superior
- Dart SDK 3.2.3 ou superior
- Android Studio ou VS Code
- Dispositivo Android/iOS ou emulador

### Configuração do Ambiente

1. **Clone o repositório:**
```bash
git clone <url-do-repositorio>
cd precinho_app
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Configure o Firebase:**
   - Crie um projeto no [Firebase Console](https://console.firebase.google.com)
   - Adicione os arquivos de configuração:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)

4. **Configure as APIs:**
   - Google Maps API Key
   - Google Sign-In (se necessário)

5. **Execute a aplicação:**
```bash
flutter run
```

### Configuração do Firebase

1. **Firestore Database:**
   - Crie as coleções: `users`, `products`, `stores`, `prices`, `shopping_lists`
   - Configure as regras de segurança

2. **Authentication:**
   - Habilite Email/Password
   - Configure Google Sign-In (opcional)

3. **Storage:**
   - Configure regras para upload de imagens

## 📊 Modelos de Dados

### User (Usuário)
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final int points;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
}
```

### Product (Produto)
```dart
class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String? imageUrl;
  final ProductCategory category;
  final String? barcode;
  final bool isApproved;
  final ModerationStatus status;
}
```

### Store (Estabelecimento)
```dart
class Store {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final StoreCategory category;
  final bool isApproved;
}
```

### Price (Preço)
```dart
class Price {
  final String id;
  final String productId;
  final String storeId;
  final String userId;
  final double value;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final double latitude;
  final double longitude;
  final bool isApproved;
}
```

## 🎯 Funcionalidades Implementadas

### ✅ Concluído
- [x] Estrutura base da aplicação
- [x] Sistema de autenticação completo
- [x] Telas principais (Login, Home, Busca, Listas, Perfil)
- [x] Modelos de dados e entidades
- [x] Serviços de API e autenticação
- [x] Gerenciamento de estado com Riverpod
- [x] Tema e design system
- [x] Validações e formatadores
- [x] Página de administração com gestão de produtos via Firestore
- [x] Tela de cadastro dedicada para a versão web
- [x] Envio de preços para o Firestore com mensagens de sucesso ou erro


### 🚧 Em Desenvolvimento
- [ ] Integração com Google Maps
- [ ] Funcionalidade de câmera
- [ ] OCR para notas fiscais
- [ ] Sistema de moderação
- [ ] Gamificação completa
- [ ] Notificações push

### 📋 Próximas Funcionalidades
- [ ] Modo offline
- [ ] Compartilhamento de listas
- [ ] Alertas de preço
- [ ] Análise de tendências
- [ ] Integração com redes sociais

## 🧪 Testes

### Executar Testes
```bash
# Testes unitários
flutter test

# Testes de integração
flutter test integration_test/

# Análise de código
flutter analyze
```

### Cobertura de Testes
- Modelos de dados
- Validadores e formatadores
- Lógica de negócio
- Widgets principais

## 📱 Capturas de Tela

*As capturas de tela serão adicionadas após a implementação completa da UI*

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

Para suporte e dúvidas:
- Email: suporte@precinho.com
- Website: https://precinho.com
- Issues: [GitHub Issues](link-para-issues)

## 🔄 Changelog

### v1.0.0 (Em desenvolvimento)
- Implementação inicial
- Sistema de autenticação
- Telas principais
- Estrutura base da aplicação

---

**Desenvolvido com ❤️ usando Flutter**

