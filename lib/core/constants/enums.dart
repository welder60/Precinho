// Enums da aplicação Precinho

// Estado de carregamento
enum LoadingState {
  initial('initial', 'Inicial'),
  loading('loading', 'Carregando'),
  success('success', 'Sucesso'),
  error('error', 'Erro');

  const LoadingState(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Papel do usuário no sistema
enum UserRole {
  user('user', 'Usuário'),
  moderator('moderator', 'Moderador'),
  admin('admin', 'Administrador');

  const UserRole(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Status de moderação
enum ModerationStatus {
  pending('pending', 'Pendente'),
  approved('approved', 'Aprovado'),
  rejected('rejected', 'Rejeitado'),
  underReview('under_review', 'Em Análise');

  const ModerationStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Categoria de comércio
enum StoreCategory {
  supermarket('supermarket', 'Supermercado'),
  hypermarket('hypermarket', 'Hipermercado'),
  minimarket('minimarket', 'Minimercado'),
  pharmacy('pharmacy', 'Farmácia'),
  bakery('bakery', 'Padaria'),
  butcher('butcher', 'Açougue'),
  greengrocer('greengrocer', 'Hortifrúti'),
  other('other', 'Outros');

  const StoreCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Categoria de produto
enum ProductCategory {
  food('food', 'Alimentos'),
  beverages('beverages', 'Bebidas'),
  cleaning('cleaning', 'Limpeza'),
  hygiene('hygiene', 'Higiene'),
  pharmacy('pharmacy', 'Farmácia'),
  bakery('bakery', 'Padaria'),
  meat('meat', 'Carnes'),
  dairy('dairy', 'Laticínios'),
  frozen('frozen', 'Congelados'),
  other('other', 'Outros');

  const ProductCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Tipo de ordenação para busca
enum SortType {
  price('price', 'Menor Preço'),
  distance('distance', 'Mais Próximo'),
  newest('newest', 'Mais Recente'),
  rating('rating', 'Melhor Avaliado');

  const SortType(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Status da lista de compras
enum ShoppingListStatus {
  active('active', 'Ativa'),
  completed('completed', 'Concluída'),
  archived('archived', 'Arquivada');

  const ShoppingListStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Tipo de notificação
enum NotificationType {
  priceAlert('price_alert', 'Alerta de Preço'),
  newStore('new_store', 'Novo Comércio'),
  moderationResult('moderation_result', 'Resultado da Moderação'),
  achievement('achievement', 'Conquista'),
  system('system', 'Sistema');

  const NotificationType(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Tipo de conquista/badge
enum AchievementType {
  firstPrice('first_price', 'Primeiro Preço'),
  priceHunter('price_hunter', 'Caçador de Preços'),
  storeExplorer('store_explorer', 'Explorador de Comércios'),
  topContributor('top_contributor', 'Top Contribuidor'),
  moderatorHelper('moderator_helper', 'Ajudante de Moderador'),
  loyalUser('loyal_user', 'Usuário Fiel');

  const AchievementType(this.value, this.displayName);
  final String value;
  final String displayName;
}

// Tipo de erro
enum ErrorType {
  network('network', 'Erro de Conexão'),
  server('server', 'Erro do Servidor'),
  validation('validation', 'Erro de Validação'),
  authentication('authentication', 'Erro de Autenticação'),
  permission('permission', 'Erro de Permissão'),
  unknown('unknown', 'Erro Desconhecido');

  const ErrorType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum ContributionType {
  pricePhoto('price_photo', 'Foto de Preço'),
  invoice('invoice', 'Nota Fiscal');

  const ContributionType(this.value, this.displayName);
  final String value;
  final String displayName;
}

