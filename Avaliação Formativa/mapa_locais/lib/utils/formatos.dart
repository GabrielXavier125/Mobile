/// Funções de formatação e regras simples exibidas na interface.
library;

String formatarNumero(double valor, {int casas = 1}) =>
    valor.toStringAsFixed(casas).replaceAll('.', ',');

String formatarDistancia(double km) => '${formatarNumero(km)} km';

/// Converte texto digitado ("4,5" ou "4.5") em número.
double? lerNumero(String texto) => double.tryParse(texto.trim().replaceAll(',', '.'));

final _regexHorario = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)\s*-\s*([01]\d|2[0-4]):([0-5]\d)$');

bool horarioValido(String horario) =>
    horario.trim().toLowerCase() == '24 horas' || _regexHorario.hasMatch(horario.trim());

/// Indica se o local está aberto em [agora], a partir de "HH:MM - HH:MM".
/// Retorna null quando o horário não está em um formato reconhecido.
bool? estaAberto(String horario, DateTime agora) {
  final texto = horario.trim().toLowerCase();
  if (texto == '24 horas') return true;

  final m = _regexHorario.firstMatch(horario.trim());
  if (m == null) return null;

  final abre = int.parse(m[1]!) * 60 + int.parse(m[2]!);
  final fecha = int.parse(m[3]!) * 60 + int.parse(m[4]!);
  final minutos = agora.hour * 60 + agora.minute;

  if (abre == fecha) return true;
  if (abre < fecha) return minutos >= abre && minutos < fecha;
  return minutos >= abre || minutos < fecha; // atravessa a meia-noite
}
