import '../constants/app_constants.dart';

class Validators {
  // Validação de email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email inválido';
    }
    
    return null;
  }

  // Validação de senha
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (password.length < AppConstants.minPasswordLength) {
      return 'Senha deve ter pelo menos ${AppConstants.minPasswordLength} caracteres';
    }
    
    return null;
  }

  // Validação de nome
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (name.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (name.length > 50) {
      return 'Nome deve ter no máximo 50 caracteres';
    }
    
    return null;
  }

  // Validação de nome do produto
  static String? validateProductName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nome do produto é obrigatório';
    }
    
    if (name.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (name.length > AppConstants.maxProductNameLength) {
      return 'Nome deve ter no máximo ${AppConstants.maxProductNameLength} caracteres';
    }
    
    return null;
  }

  // Validação de volume do produto
  static String? validateVolume(String? volume) {
    if (volume == null || volume.isEmpty) {
      return 'Volume é obrigatório';
    }

    final parsed = double.tryParse(volume.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Volume inválido';
    }

    if (parsed <= 0) {
      return 'Volume deve ser maior que zero';
    }

    if (parsed > 9999) {
      return 'Volume muito alto';
    }

    return null;
  }

  // Validação de nome da loja
  static String? validateStoreName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nome da loja é obrigatório';
    }
    
    if (name.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (name.length > AppConstants.maxStoreNameLength) {
      return 'Nome deve ter no máximo ${AppConstants.maxStoreNameLength} caracteres';
    }
    
    return null;
  }

  // Validação de preço
  static String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return 'Preço é obrigatório';
    }
    
    final cleanPrice = price.replaceAll(RegExp(r'[^\d,.]'), '');
    final normalizedPrice = cleanPrice.replaceAll(',', '.');
    
    final parsedPrice = double.tryParse(normalizedPrice);
    if (parsedPrice == null) {
      return 'Preço inválido';
    }
    
    if (parsedPrice <= 0) {
      return 'Preço deve ser maior que zero';
    }
    
    if (parsedPrice > 999999.99) {
      return 'Preço muito alto';
    }
    
    return null;
  }

  // Validação de telefone
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null; // Telefone é opcional
    }
    
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return 'Telefone inválido';
    }
    
    return null;
  }

  // Validação de descrição
  static String? validateDescription(String? description) {
    if (description != null && description.length > AppConstants.maxDescriptionLength) {
      return 'Descrição deve ter no máximo ${AppConstants.maxDescriptionLength} caracteres';
    }
    
    return null;
  }

  // Validação de endereço
  static String? validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'Endereço é obrigatório';
    }
    
    if (address.length < 10) {
      return 'Endereço deve ter pelo menos 10 caracteres';
    }
    
    if (address.length > 200) {
      return 'Endereço deve ter no máximo 200 caracteres';
    }
    
    return null;
  }

  // Validação de código de barras
  static String? validateBarcode(String? barcode) {
    if (barcode == null || barcode.isEmpty) {
      return null; // Código de barras é opcional
    }
    
    final cleanBarcode = barcode.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanBarcode.length < 8 || cleanBarcode.length > 14) {
      return 'Código de barras inválido';
    }
    
    return null;
  }

  // Validação de coordenadas
  static String? validateLatitude(double? latitude) {
    if (latitude == null) {
      return 'Latitude é obrigatória';
    }
    
    if (latitude < -90 || latitude > 90) {
      return 'Latitude inválida';
    }
    
    return null;
  }

  static String? validateLongitude(double? longitude) {
    if (longitude == null) {
      return 'Longitude é obrigatória';
    }
    
    if (longitude < -180 || longitude > 180) {
      return 'Longitude inválida';
    }
    
    return null;
  }

  // Validação de quantidade
  static String? validateQuantity(String? quantity) {
    if (quantity == null || quantity.isEmpty) {
      return 'Quantidade é obrigatória';
    }
    
    final parsedQuantity = int.tryParse(quantity);
    if (parsedQuantity == null) {
      return 'Quantidade inválida';
    }
    
    if (parsedQuantity <= 0) {
      return 'Quantidade deve ser maior que zero';
    }
    
    if (parsedQuantity > 999) {
      return 'Quantidade muito alta';
    }
    
    return null;
  }
}

