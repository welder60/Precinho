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

  // Validação de nome do comércio
  static String? validateStoreName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Nome do comércio é obrigatório';
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

  // Validação de marca (opcional)
  static String? validateBrand(String? brand) {
    if (brand == null || brand.isEmpty) {
      return null; // Marca é opcional
    }

    if (brand.length < 2) {
      return 'Marca deve ter pelo menos 2 caracteres';
    }

    if (brand.length > AppConstants.maxProductNameLength) {
      return 'Marca deve ter no máximo ${AppConstants.maxProductNameLength} caracteres';
    }

    return null;
  }

  // Validação de código NCM (opcional)
  static String? validateNcmCode(String? ncm) {
    if (ncm == null || ncm.isEmpty) {
      return null;
    }

    final clean = ncm.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.length != 8) {
      return 'NCM deve ter 8 dígitos';
    }

    return null;
  }

  // Verifica se a chave de acesso da nota fiscal é válida
  static bool isValidInvoiceAccessKey(String key) {
    final clean = key.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 44) return false;
    final digits = clean.split('').map(int.parse).toList();
    var weight = 2;
    var sum = 0;
    for (var i = digits.length - 2; i >= 0; i--) {
      sum += digits[i] * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    final mod = sum % 11;
    final dv = mod == 0 || mod == 1 ? 0 : 11 - mod;
    return dv == digits.last;
  }

  // Validação de chave de acesso de nota fiscal
  static String? validateInvoiceAccessKey(String? key) {
    if (key == null || key.isEmpty) {
      return 'Chave obrigatória';
    }
    final clean = key.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 44) {
      return 'Chave deve ter 44 dígitos';
    }
    if (!isValidInvoiceAccessKey(clean)) {
      return 'Chave inválida';
    }
    return null;
  }

  // Validação de CNPJ
  static String? validateCnpj(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) {
      return null; // CNPJ é opcional
    }

    final cleanCnpj = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCnpj.length != 14) {
      return 'CNPJ inválido';
    }

    return null;
  }

  

  // Validação de CPF
  static String? validateCpf(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'CPF é obrigatório';
    }

    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCpf.length != 11) {
      return 'CPF inválido';
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(cleanCpf)) {
      return 'CPF inválido';
    }

    int calcDigit(String base, int length) {
      var sum = 0;
      for (var i = 0; i < length; i++) {
        sum += int.parse(base[i]) * ((length + 1) - i);
      }
      final mod = sum % 11;
      return mod < 2 ? 0 : 11 - mod;
    }

    final digit1 = calcDigit(cleanCpf, 9);
    final digit2 = calcDigit(cleanCpf, 10);

    if (digit1 != int.parse(cleanCpf[9]) || digit2 != int.parse(cleanCpf[10])) {
      return 'CPF inválido';
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

