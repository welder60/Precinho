import 'package:intl/intl.dart';

class Formatters {
  // Formatador de moeda brasileira
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  // Formatador de data
  static final _dateFormatter = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final _timeFormatter = DateFormat('HH:mm');

  // Formatador de telefone
  static final _phoneRegex = RegExp(r'^(\d{2})(\d{4,5})(\d{4})$');

  // Formatação de preço
  static String formatPrice(double price) {
    return _currencyFormatter.format(price);
  }

  // Formatação de preço sem símbolo
  static String formatPriceValue(double price) {
    return price.toStringAsFixed(2).replaceAll('.', ',');
  }

  // Parse de preço
  static double? parsePrice(String priceText) {
    final cleanPrice = priceText
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();
    
    return double.tryParse(cleanPrice);
  }

  // Formatação de data
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  // Formatação de data e hora
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  // Formatação de hora
  static String formatTime(DateTime time) {
    return _timeFormatter.format(time);
  }

  // Formatação relativa de tempo
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'há 1 ano' : 'há $years anos';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'há 1 mês' : 'há $months meses';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'há 1 dia' : 'há ${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'há 1 hora' : 'há ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'há 1 minuto' : 'há ${difference.inMinutes} minutos';
    } else {
      return 'agora';
    }
  }

  // Formatação de telefone
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length == 11) {
      final match = _phoneRegex.firstMatch(cleanPhone);
      if (match != null) {
        return '(${match.group(1)}) ${match.group(2)}-${match.group(3)}';
      }
    } else if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    }
    
    return phone;
  }

  // Formatação de distância
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '${meters}m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  // Formatação de pontos
  static String formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M pts';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K pts';
    } else {
      return '$points pts';
    }
  }

  // Formatação de porcentagem
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Formatação de avaliação
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  // Formatação de número com separador de milhares
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'pt_BR').format(number);
  }

  // Formatação de tamanho de arquivo
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  // Capitalização de texto
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalização de cada palavra
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Formatação de CEP
  static String formatCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
    }
    return cep;
  }

  // Formatação de CNPJ
  static String formatCnpj(String cnpj) {
    final cleanCnpj = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCnpj.length == 14) {
      return '${cleanCnpj.substring(0, 2)}.${cleanCnpj.substring(2, 5)}.${cleanCnpj.substring(5, 8)}/${cleanCnpj.substring(8, 12)}-${cleanCnpj.substring(12)}';
    }
    return cnpj;
  }
}

