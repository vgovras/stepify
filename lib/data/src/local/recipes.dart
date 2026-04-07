import '../../../core/core.dart';

/// All recipes available in MVP.
final List<Recipe> allRecipes = [borschRecipe, omeletteRecipe];

// ═══════════════════════════════════════════════════════════════
// BORSCHT — 24 steps with parallel DAG, bg timers, timerDeps
// ═══════════════════════════════════════════════════════════════

const borschRecipe = Recipe(
  id: 'borscht',
  name: 'Борщ Червоний',
  emoji: '🍲',
  baseServings: 4,
  timeMinutes: 90,
  kcalPerServing: 320,
  difficulty: Difficulty.medium,
  category: RecipeCategory.soup,
  rating: 4.9,
  reviewCount: 234,
  tags: ['Українська', 'Паралельний'],
  gradientColors: (0xFF3D1010, 0xFF1A0808),
  ingredients: _borschIngredients,
  steps: _borschSteps,
);

const List<Ingredient> _borschIngredients = [
  Ingredient(
    name: 'Яловичина або свинина на кістці',
    amount: 500,
    unit: 'г',
    category: IngredientCategory.meat,
  ),
  Ingredient(
    name: 'Буряк середній',
    amount: 2,
    unit: 'шт',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Картопля',
    amount: 4,
    unit: 'шт',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Капуста свіжа',
    amount: 300,
    unit: 'г',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Морква',
    amount: 1,
    unit: 'шт',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Цибуля ріпчаста',
    amount: 1,
    unit: 'шт',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Томатна паста',
    amount: 2,
    unit: 'ст.л.',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Олія соняшникова',
    amount: 3,
    unit: 'ст.л.',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Часник',
    amount: 3,
    unit: 'зубч.',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Лимонна кислота або оцет',
    amount: 1,
    unit: 'ч.л.',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Цукор',
    amount: 1,
    unit: 'ч.л.',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Лавровий лист',
    amount: 2,
    unit: 'шт',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Перець горошком',
    amount: 5,
    unit: 'шт',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Сіль',
    amount: 1.5,
    unit: 'ч.л.',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Сметана (для подачі)',
    amount: 100,
    unit: 'г',
    category: IngredientCategory.dairy,
  ),
  Ingredient(
    name: 'Кріп або петрушка',
    amount: 0.5,
    unit: 'пучок',
    category: IngredientCategory.vegs,
  ),
];

/// Borscht steps — ported 1:1 from demo.html STEPS_BORSCHT.
///
/// IDs are non-sequential to match the original demo data.
/// The order in this list does not matter — [pickNextStep] sorts by weight.
const List<RecipeStep> _borschSteps = [
  // ── М'ясо на прогрів ──────────────────────────────────────
  RecipeStep(
    id: 1,
    weight: 10,
    deps: [],
    text: "Дістаньте м'ясо з холодильника, покладіть на тарілку",
    note: StepNote(
      type: NoteType.tip,
      text: "💡 Поки м'ясо гріється 20 хв — наріжте всі овочі",
    ),
    timer: StepTimer(
      minutes: 20,
      label: "М'ясо прогрівається",
      isBackground: true,
    ),
    waitTimer: false,
  ),

  // ── Нарізка (одразу після 1, незалежно від бульйону) ──────
  RecipeStep(
    id: 7,
    weight: 70,
    deps: [1],
    text:
        'Картопля (4 шт): наріжте кубиками ~2×2 см — одразу в миску '
        'з холодною водою',
    note: StepNote(
      type: NoteType.warn,
      text:
          '⚠️ Без холодної води почорніє за 10 хвилин. Залишається '
          'в мисці до кроку "додати в борщ"',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 9,
    weight: 90,
    deps: [1],
    text: 'Буряк (2 шт): натріть на крупній тертці — відкладіть в миску',
    note: StepNote(
      type: NoteType.warn,
      text:
          '⚠️ Буряк фарбує — рукавички або намастіть руки олією. '
          'Піде в засмажку',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 10,
    weight: 100,
    deps: [1],
    text: 'Морква (1 шт): натріть на крупній тертці — відкладіть в миску',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Піде в засмажку разом з цибулею',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 11,
    weight: 110,
    deps: [1],
    text: 'Цибуля (1 шт): дрібні кубики ~5 мм — відкладіть в миску',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Піде в засмажку. Нарізана цибуля може полежати 15–20 хв',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 12,
    weight: 120,
    deps: [1],
    text: 'Капуста (300 г): тонко нашинкуйте ~3 мм — відкладіть в миску',
    note: StepNote(
      type: NoteType.tip,
      text: "💡 Піде в борщ першою — після того як дістанете м'ясо",
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 13,
    weight: 130,
    deps: [1],
    text: 'Часник (3 зубчики): розчавіть лезом ножа — відкладіть окремо',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Піде в самому кінці. Не змішуйте з іншими овочами',
    ),
    waitTimer: false,
  ),

  // ── Засмажка (після нарізки цибулі + моркви + буряка) ─────
  RecipeStep(
    id: 14,
    weight: 140,
    deps: [9, 10, 11],
    text:
        'Розігрійте сковорідку на середньому вогні, налийте 3 ст.л. '
        'олії. Додайте цибулю і моркву',
    note: StepNote(
      type: NoteType.warn,
      text: '⚠️ Тільки золотиста цибуля! Коричнева — гірчить',
    ),
    timer: StepTimer(
      minutes: 5,
      label: 'Цибуля і морква смажаться',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 16,
    weight: 160,
    deps: [14],
    text:
        'Додайте буряк + 1 ч.л. лимонної кислоти (або оцту) + '
        '1 ч.л. цукру, перемішайте',
    note: StepNote(
      type: NoteType.warn,
      text:
          "⚠️ Лимонна кислота або оцет обов'язково — без них борщ "
          'стане коричневим',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 18,
    weight: 180,
    deps: [16],
    text: 'Додайте 2 ст.л. томатної пасти, тушкуйте помішуючи',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Паста має потемніти і загуснути — це карамелізація',
    ),
    timer: StepTimer(
      minutes: 6,
      label: 'Засмажка тушкується',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 19,
    weight: 190,
    deps: [18],
    text: 'Зніміть засмажку з вогню — готова. Відставте в сторону',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Засмажка чекатиме поки не буде готовий бульйон',
    ),
    waitTimer: false,
  ),

  // ── Вода в каструлю (одразу після 1) ──────────────────────
  RecipeStep(
    id: 3,
    weight: 30,
    deps: [1],
    text: 'Залийте 3 л холодної води в каструлю 5–6 л',
    note: StepNote(
      type: NoteType.tip,
      text: "💡 Холодна вода обов'язково — гаряча дає каламутний бульйон",
    ),
    waitTimer: false,
  ),

  // ── Промити м'ясо (тільки після 20хв таймера) ────────────
  RecipeStep(
    id: 2,
    weight: 200,
    deps: [1],
    timerDep: 1,
    text:
        "М'ясо прогрілось — промийте під холодною водою, покладіть "
        'ЦІЛИМ шматком у каструлю',
    note: StepNote(
      type: NoteType.warn,
      text: "⚠️ Нарізане м'ясо зробить бульйон каламутним",
    ),
    waitTimer: false,
  ),

  // ── Бульйон ──────────────────────────────────────────────
  RecipeStep(
    id: 5,
    weight: 220,
    deps: [2, 3],
    text:
        'Поставте на середній вогонь, доведіть до кипіння — знімайте '
        'сіру піну шумівкою',
    note: StepNote(
      type: NoteType.warn,
      text:
          "⚠️ Не відходьте — піна з'являється швидко. Не накривайте "
          'кришкою',
    ),
    timer: StepTimer(minutes: 10, label: 'Вода закипає', isBackground: false),
    waitTimer: true,
  ),
  RecipeStep(
    id: 6,
    weight: 230,
    deps: [5],
    text:
        'Додайте лавровий лист (2 шт) + перець горошком (5 шт). '
        'Зменшіть вогонь до мінімуму, накрийте кришкою',
    note: StepNote(
      type: NoteType.tip,
      text:
          '💡 Запустіть таймер 90 хв і займайтеся засмажкою якщо ще '
          'не зробили',
    ),
    timer: StepTimer(
      minutes: 90,
      label: 'Бульйон вариться',
      isBackground: true,
    ),
    waitTimer: false,
  ),

  // ── Збираємо борщ (після бульйону + засмажки + нарізки) ──
  RecipeStep(
    id: 20,
    weight: 300,
    deps: [6, 12, 19],
    timerDep: 6,
    text:
        "Бульйон готовий — дістаньте м'ясо шумівкою на дошку. "
        'Викиньте лавровий лист',
    note: StepNote(
      type: NoteType.tip,
      text: "💡 М'ясо хай трохи охолоне — поки закидайте капусту",
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 21,
    weight: 310,
    deps: [20],
    text: 'Додайте нашатковану капусту в киплячий бульйон',
    note: StepNote(
      type: NoteType.warn,
      text: '⚠️ Капуста першою — їй треба більше часу ніж картоплі',
    ),
    timer: StepTimer(
      minutes: 5,
      label: 'Капуста вариться',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 22,
    weight: 320,
    deps: [21],
    text: 'Злийте воду з миски, додайте картоплю в бульйон',
    note: StepNote(type: NoteType.tip, text: '💡 Картопля йде після капусти'),
    timer: StepTimer(
      minutes: 10,
      label: 'Картопля вариться',
      isBackground: false,
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 23,
    weight: 330,
    deps: [22],
    text:
        "Поки вариться — наріжте м'ясо: зніміть з кістки, "
        'шматочки ~3×3 см',
    note: StepNote(
      type: NoteType.tip,
      text:
          "💡 Або розберіть руками на волокна. М'ясо поки відкладіть "
          '— піде в кінці',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 24,
    weight: 340,
    deps: [23, 22],
    text:
        'Картопля напівготова — додайте всю засмажку, перемішайте. '
        'Посоліть 1.5 ч.л., поперчіть, спробуйте',
    note: StepNote(
      type: NoteType.tip,
      text:
          '💡 Борщ одразу стане яскраво-червоним. Трохи пересолено '
          "— норма, при настоюванні м'якшає",
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 26,
    weight: 360,
    deps: [24],
    text: "Поверніть нарізане м'ясо в борщ. Варіть 10 хвилин",
    timer: StepTimer(
      minutes: 10,
      label: 'Борщ доварюється',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 27,
    weight: 370,
    deps: [26, 13],
    text:
        'Додайте розчавлений часник + зелень (кріп/петрушку). '
        'Доведіть до кипіння і одразу вимкніть',
    note: StepNote(
      type: NoteType.tip,
      text:
          "💡 Часник і зелень — тільки наприкінці. Не кип'ятіть "
          '— втратять аромат',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 28,
    weight: 380,
    deps: [27],
    text: 'Накрийте кришкою — настоюється 25 хвилин. Не відкривайте',
    note: StepNote(
      type: NoteType.pro,
      text:
          '🏆 Наступного дня смакує НАБАГАТО краще — всі смаки '
          'зливаються',
    ),
    timer: StepTimer(
      minutes: 25,
      label: 'Борщ настоюється',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 29,
    weight: 390,
    deps: [28],
    text:
        'Розлийте по тарілках. Сметана ложкою зверху — не мішати! '
        'Подавайте з хлібом або пампушками',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Сметана тане сама — не додавати в каструлю',
    ),
    waitTimer: false,
  ),
];

// ═══════════════════════════════════════════════════════════════
// OMELETTE — 13 linear steps
// ═══════════════════════════════════════════════════════════════

const omeletteRecipe = Recipe(
  id: 'omelette',
  name: 'Омлет з начинкою',
  emoji: '🍳',
  baseServings: 2,
  timeMinutes: 25,
  kcalPerServing: 420,
  difficulty: Difficulty.easy,
  category: RecipeCategory.breakfast,
  rating: 4.8,
  reviewCount: 156,
  tags: ['Сніданок', 'Швидко'],
  gradientColors: (0xFF2A1F08, 0xFF1A1204),
  ingredients: _omeletteIngredients,
  steps: _omeletteSteps,
);

const List<Ingredient> _omeletteIngredients = [
  Ingredient(
    name: 'Яйця',
    amount: 4,
    unit: 'шт',
    category: IngredientCategory.eggs,
  ),
  Ingredient(
    name: 'Картопля',
    amount: 2,
    unit: 'шт',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Помідор',
    amount: 1,
    unit: 'шт',
    category: IngredientCategory.vegs,
  ),
  Ingredient(
    name: 'Твердий сир',
    amount: 60,
    unit: 'г',
    category: IngredientCategory.dairy,
  ),
  Ingredient(
    name: 'Хліб (для грінок)',
    amount: 2,
    unit: 'скибки',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Вершкове масло',
    amount: 1,
    unit: 'ст.л.',
    category: IngredientCategory.dairy,
  ),
  Ingredient(
    name: 'Олія соняшникова',
    amount: 2,
    unit: 'ст.л.',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Сіль, перець',
    unit: 'за смаком',
    category: IngredientCategory.other,
  ),
  Ingredient(
    name: 'Зелень (кріп/цибуля)',
    amount: 0.25,
    unit: 'пучок',
    category: IngredientCategory.vegs,
  ),
];

const List<RecipeStep> _omeletteSteps = [
  RecipeStep(
    id: 1,
    weight: 10,
    deps: [],
    text: 'Хліб (2 скибки): наріжте кубиками ~1×1 см',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Черствий хліб дає хрусткіші грінки',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 2,
    weight: 20,
    deps: [1],
    text:
        'Смажте кубики хліба в 1 ст.л. олії на середньому вогні до '
        'золотистої скоринки — відкладіть',
    note: StepNote(
      type: NoteType.tip,
      text:
          '💡 Постійно помішуйте — підгорають швидко. Готові грінки '
          'відкладіть на паперовий рушник',
    ),
    timer: StepTimer(
      minutes: 4,
      label: 'Грінки смажаться',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 3,
    weight: 30,
    deps: [],
    text: 'Картопля (2 шт): наріжте тонкими кружальцями ~3 мм',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Тонко — щоб швидше приготувалась на пательні',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 4,
    weight: 40,
    deps: [3, 2],
    text:
        "Смажте картоплю в 1 ст.л. олії до м'якості і золотистого "
        'кольору',
    note: StepNote(
      type: NoteType.warn,
      text: '⚠️ Не мішайте перші 2 хв — хай схопиться скоринка',
    ),
    timer: StepTimer(
      minutes: 8,
      label: 'Картопля смажиться',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 5,
    weight: 50,
    deps: [3],
    text: 'Помідор: наріжте кубиками ~1 см, відкладіть',
    note: StepNote(
      type: NoteType.tip,
      text: "💡 Щільні помідори — краще. М'які дадуть забагато соку",
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 6,
    weight: 60,
    deps: [3],
    text: 'Сир (60 г): натріть на крупній тертці, відкладіть',
    waitTimer: false,
  ),
  RecipeStep(
    id: 7,
    weight: 80,
    deps: [4],
    text:
        'Яйця (4 шт): розбийте в миску, посоліть і поперчіть, збийте '
        'виделкою',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Без молока — яйця чисто. 30 секунд виделкою, не міксер',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 8,
    weight: 90,
    deps: [7],
    text:
        'Зменшіть вогонь до середнього. На картоплю додайте вершкове '
        'масло (1 ст.л.) і дайте розтанути',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Масло дає смак і не дасть омлету прилипнути',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 9,
    weight: 100,
    deps: [8],
    text: 'Залийте яйця рівномірно поверх картоплі. Не мішайте',
    note: StepNote(
      type: NoteType.warn,
      text:
          '⚠️ Не мішати! Дайте краям схопитись — потім посунете '
          'лопаткою',
    ),
    timer: StepTimer(
      minutes: 2,
      label: 'Омлет схоплюється',
      isBackground: false,
    ),
    waitTimer: true,
  ),
  RecipeStep(
    id: 10,
    weight: 110,
    deps: [9],
    text: 'Розкладіть помідори і половину сиру по половині омлету',
    note: StepNote(
      type: NoteType.tip,
      text: '💡 Тільки на одну половину — зараз будемо складати',
    ),
    waitTimer: false,
  ),
  RecipeStep(
    id: 11,
    weight: 120,
    deps: [10],
    text: 'Складіть омлет навпіл лопаткою, накрийте кришкою',
    note: StepNote(
      type: NoteType.tip,
      text: "💡 Обережно — яйця ще м'які всередині, це нормально",
    ),
    timer: StepTimer(minutes: 2, label: 'Сир плавиться', isBackground: false),
    waitTimer: true,
  ),
  RecipeStep(
    id: 12,
    weight: 130,
    deps: [11],
    text: 'Посипте зверху сиром що залишився і грінками',
    waitTimer: false,
  ),
  RecipeStep(
    id: 13,
    weight: 140,
    deps: [12],
    text: 'Посипте зеленню, подавайте одразу — омлет не чекає!',
    note: StepNote(
      type: NoteType.pro,
      text: '🏆 Омлет їдять одразу зі сковорідки — через 2 хв вже не те',
    ),
    waitTimer: false,
  ),
];
