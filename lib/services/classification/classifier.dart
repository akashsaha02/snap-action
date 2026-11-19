import '../../core/constants/system_categories.dart';
import '../../core/database/enums.dart';
import '../entity_extraction/entity_extractor.dart';

class UserRule {
  const UserRule({required this.keyword, required this.categorySlug});

  final String keyword;
  final String categorySlug;
}

class ClassificationInput {
  const ClassificationInput({
    required this.text,
    required this.extraction,
    this.userRules = const [],
  });

  final String text;
  final ExtractionResult extraction;
  final List<UserRule> userRules;
}

class ClassificationResult {
  const ClassificationResult({
    required this.categorySlug,
    required this.score,
    required this.rawScores,
    required this.evidence,
    required this.needsConfirmation,
  });

  final String categorySlug;

  /// Share of total rule evidence held by the winning category (0..1). It
  /// ranks categories; it is not a calibrated probability.
  final double score;
  final Map<String, double> rawScores;
  final Map<String, List<String>> evidence;

  /// The top categories scored too closely to decide automatically.
  final bool needsConfirmation;
}

/// Pluggable so an on-device ML model can replace or complement the rules.
abstract interface class ScreenshotClassifier {
  ClassificationResult classify(ClassificationInput input);
}

class _Rule {
  const _Rule(this.pattern, this.weight, this.label);

  final RegExp pattern;
  final double weight;
  final String label;
}

_Rule _kw(String words, double weight) => _Rule(
  RegExp('\\b(?:$words)\\b', caseSensitive: false, unicode: true),
  weight,
  words.split('|').first,
);

class RuleBasedClassifier implements ScreenshotClassifier {
  const RuleBasedClassifier({this.minimumEvidence = 2.0, this.tieRatio = 0.75});

  /// Below this raw score the screenshot is filed under Other.
  final double minimumEvidence;

  /// If the runner-up reaches this fraction of the winner, ask the user.
  final double tieRatio;

  static final Map<String, List<_Rule>> _rules = {
    CategorySlugs.shopping: [
      _kw(
        'add to cart|add to bag|add to basket|in den warenkorb|ajouter au panier|añadir al carrito',
        3,
      ),
      _kw('buy now|jetzt kaufen|acheter|comprar ahora|shop now|order now', 3),
      _kw(
        'free shipping|free delivery|kostenloser versand|livraison gratuite|envío gratis',
        2,
      ),
      _kw('in stock|out of stock|only \\d+ left|auf lager', 2),
      _kw(
        'sale|discount|% off|deal|coupon|promo code|rabatt|soldes|oferta|descuento',
        1.5,
      ),
      _kw(
        'checkout|wishlist|product|size|colour|color|reviews|ratings|seller|merchant',
        1,
      ),
      _kw('amazon|ebay|etsy|zalando|aliexpress|daraz|ikea|shein', 2),
    ],
    CategorySlugs.travel: [
      _kw('booking confirmation|boarding pass|e-ticket|itinerary', 3),
      _kw(
        'flight|flug|vol|vuelo|airline|airport|flughafen|aéroport|aeropuerto',
        2.5,
      ),
      _kw('departure|arrival|abflug|ankunft|départ|arrivée|salida|llegada', 2),
      _kw('boarding|gate|terminal|seat|baggage|check-in|layover', 2),
      _kw(
        'hotel|hostel|airbnb|check-out|reservation|reservierung|réservation|reserva',
        1.5,
      ),
      _kw('train|bahn|railway|bus ticket|platform', 1.5),
      _kw('passport|visa', 1),
    ],
    CategorySlugs.education: [
      _kw('assignment|homework|coursework|hausarbeit|devoir|tarea', 3),
      _kw('exam|examination|midterm|final exam|quiz|prüfung|examen', 3),
      _kw(
        'semester|lecture|tutorial|syllabus|course|module|vorlesung|cours|curso',
        2,
      ),
      _kw(
        "university|college|school|campus|faculty|universität|université|universidad|master'?s|bachelor'?s|phd",
        2,
      ),
      _kw(
        'scholarship|admission|enrol?ment|application portal|stipendium|bourse|beca',
        2,
      ),
      _kw('submission deadline|submit by|due date|grade|gpa|credits', 1.5),
      _kw('theorem|definition|equation|chapter|notes|study|formula', 1),
    ],
    CategorySlugs.events: [
      _kw(
        'conference|concert|festival|meetup|webinar|workshop|summit|exhibition|konzert|concierto',
        3,
      ),
      _kw(
        'registration|register now|rsvp|get tickets|tickets|sold out|anmeldung|inscription|inscripción',
        2.5,
      ),
      _kw('venue|doors open|line-?up|stage|speakers|agenda|keynote', 2),
      _kw('event|veranstaltung|événement|evento|party|celebration|show', 1.5),
      _kw('save the date|join us|live', 1.5),
    ],
    CategorySlugs.finance: [
      _kw('invoice|receipt|rechnung|quittung|facture|reçu|factura|recibo', 3),
      _kw(
        'payment successful|payment received|paid|transaction|überweisung|virement|transferencia',
        3,
      ),
      _kw(
        'total amount|amount paid|subtotal|grand total|total|tax|vat|mwst|tva|iva',
        2,
      ),
      _kw(
        'order (?:number|id|no)|order reference|transaction id|reference number',
        2,
      ),
      _kw(
        'bank|account|balance|iban|credit card|debit|upi|bkash|nagad|paypal|wise|revolut',
        1.5,
      ),
      _kw('refund|charged|billing|statement', 1.5),
    ],
    CategorySlugs.jobs: [
      _kw(
        "we're hiring|we are hiring|hiring|job opening|vacancy|stellenangebot|offre d'emploi|oferta de empleo",
        3,
      ),
      _kw(
        'apply now|application deadline|how to apply|submit your cv|bewerben',
        3,
      ),
      _kw(
        'job description|responsibilities|requirements|qualifications|nice to have',
        2.5,
      ),
      _kw(
        'salary|compensation|benefits|full-?time|part-?time|remote|hybrid|internship|praktikum|stage',
        2,
      ),
      _kw('linkedin|indeed|glassdoor|recruiter|resume|cv|interview', 2),
      _kw('career|position|role|candidate|years of experience', 1),
    ],
    CategorySlugs.technology: [
      _kw(
        'github|gitlab|stack ?overflow|npm|pub\\.dev|pypi|docker|kubernetes',
        3,
      ),
      _kw(
        'error|exception|stack trace|traceback|segfault|null pointer|undefined is not',
        2.5,
      ),
      _kw(
        'api|sdk|endpoint|json|http|localhost|repository|commit|pull request|branch',
        2,
      ),
      _kw(
        'function|class|import|const|return|async|await|compile|build failed|deploy',
        1.5,
      ),
      _kw('documentation|docs|install|terminal|command|config', 1),
    ],
    CategorySlugs.food: [
      _kw(
        'recipe|rezept|recette|receta|ingredients|zutaten|ingrédients|ingredientes',
        3,
      ),
      _kw(
        'tbsp|tsp|tablespoon|teaspoon|cups?|grams?|preheat|oven|bake|simmer|whisk|stir',
        2.5,
      ),
      _kw(
        'restaurant|café|cafe|menu|dinner|lunch|brunch|breakfast|reservation for',
        2,
      ),
      _kw('delicious|yummy|serves|prep time|cook time|vegan|vegetarian', 1.5),
    ],
    CategorySlugs.social: [
      _kw(
        'instagram|tiktok|twitter|facebook|threads|youtube|reddit|snapchat|pinterest|linkedin post',
        3,
      ),
      _kw(
        'followers|following|likes|retweets?|reposts?|comments|replies|views|subscribers',
        2,
      ),
      _kw('follow|share|reel|story|stories|post|trending|viral|hashtag', 1),
    ],
    CategorySlugs.messages: [
      _kw('whatsapp|messenger|telegram|signal|imessage|sms|text message', 3),
      _kw('typing\\.\\.\\.|online|last seen|delivered|seen|read at', 2.5),
      _kw('reply|message|chat|sent|forwarded', 1),
    ],
    CategorySlugs.locations: [
      _kw('google maps|apple maps|get directions|directions|route|navigate', 3),
      _kw(
        'open now|closes at|opening hours|öffnungszeiten|horaires|horario',
        2,
      ),
      _kw(
        'street|road|avenue|straße|strasse|rue|calle|km away|miles away|nearby',
        1.5,
      ),
    ],
    CategorySlugs.documents: [
      _kw(
        'terms and conditions|agreement|contract|certificate|license|licence|form|application form',
        2.5,
      ),
      _kw(
        'passport|id card|driving licen[cs]e|birth certificate|identity',
        2.5,
      ),
      _kw('page \\d+|section|clause|signature|signed|dated|pdf|document', 1.5),
    ],
    CategorySlugs.quotes: [
      _kw('quote|quotes|inspiration|motivation|motivational|wisdom', 2.5),
      _kw('life|dream|believe|success|happiness|love|courage|never give up', 1),
    ],
    CategorySlugs.personal: [
      _kw(
        'appointment|doctor|dentist|clinic|hospital|prescription|termin|rendez-vous|cita',
        2.5,
      ),
      _kw(
        'birthday|anniversary|wedding|family|mom|dad|reminder|to-?do|grocery list',
        2,
      ),
      _kw('wi-?fi|wlan|password|ssid', 1.5),
    ],
  };

  static const _entityBoosts = <(EntityType, String, double)>[
    (EntityType.flightReference, CategorySlugs.travel, 3),
    (EntityType.codeSnippet, CategorySlugs.technology, 3),
    (EntityType.address, CategorySlugs.locations, 1.5),
    (EntityType.wifiCredentials, CategorySlugs.personal, 2),
    (EntityType.productName, CategorySlugs.shopping, 2),
    (EntityType.eventTitle, CategorySlugs.events, 1.5),
    (EntityType.amount, CategorySlugs.shopping, 1),
    (EntityType.amount, CategorySlugs.finance, 1),
    (EntityType.orderReference, CategorySlugs.finance, 1.5),
    (EntityType.deadline, CategorySlugs.education, 0.75),
    (EntityType.deadline, CategorySlugs.jobs, 0.75),
  ];

  @override
  ClassificationResult classify(ClassificationInput input) {
    final scores = <String, double>{};
    final evidence = <String, List<String>>{};
    void add(String slug, double w, String why) {
      scores[slug] = (scores[slug] ?? 0) + w;
      (evidence[slug] ??= []).add(why);
    }

    final text = input.text;
    for (final MapEntry(key: slug, value: rules) in _rules.entries) {
      for (final rule in rules) {
        final hits = rule.pattern.allMatches(text).length;
        if (hits == 0) continue;
        // Repeated mentions add a little, capped so one word cannot dominate.
        final weight = rule.weight * (1 + 0.25 * (hits - 1).clamp(0, 2));
        add(slug, weight, rule.label);
      }
    }

    final x = input.extraction;
    for (final (type, slug, weight) in _entityBoosts) {
      if (x.has(type)) add(slug, weight, type.name);
    }
    if (x.has(EntityType.date) && x.has(EntityType.time)) {
      add(CategorySlugs.events, 1, 'date and time');
    }

    final lower = text.toLowerCase();
    for (final rule in input.userRules) {
      final k = rule.keyword.trim().toLowerCase();
      if (k.isNotEmpty && lower.contains(k)) {
        add(rule.categorySlug, 4, 'rule: ${rule.keyword}');
      }
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = scores.values.fold<double>(0, (a, b) => a + b);

    if (ranked.isEmpty || ranked.first.value < minimumEvidence) {
      return ClassificationResult(
        categorySlug: CategorySlugs.other,
        score: 0,
        rawScores: scores,
        evidence: evidence,
        needsConfirmation: false,
      );
    }

    final top = ranked.first;
    final second = ranked.length > 1 ? ranked[1].value : 0.0;
    return ClassificationResult(
      categorySlug: top.key,
      score: total == 0 ? 0 : top.value / total,
      rawScores: scores,
      evidence: evidence,
      needsConfirmation: second >= top.value * tieRatio,
    );
  }
}
