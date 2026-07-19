# Конфліктні терміни — аркуш рішень

Згенеровано автоматично з відредагованих людиною сегментів (`target state="translated"`).
Лічильники — **кількість сегментів**, де в англійському джерелі є термін, а в українській цілі — цей варіант.
Сегмент може потрапити у два рядки одразу, якщо містить обидва варіанти.

**Як заповнювати:** впишіть обраний варіант у рядок `РІШЕННЯ:`. Якщо варіанти треба
розвести за значенням, а не звести до одного — так і напишіть.

---

### damage

Сегментів із терміном у джерелі: **220**

- **шкода** — 215 (knowledge/caltrops/uk.xml :: ::Regular)
- **ушкодження** — 35 (knowledge/combatstattooltips/uk.xml :: ::ShieldCapacity)
- **пошкодження** — 32 (knowledge/combatstattooltips/uk.xml :: ::ResistanceDescription)
- _жоден із варіантів не знайдено_ — 5 (напр. dialogs/characters/bigbret1/uk.xml :: =>a7)

РІШЕННЯ: **шкода**

### points (здоров'я, псі)

Сегментів із терміном у джерелі: **95**

- **очки** — 33 (knowledge/caltrops/uk.xml :: ::Regular)
- **пункти** — 9 (knowledge/feats/uk.xml :: ::S-old)
- **бали** — 1 (knowledge/items/utilities/uk.xml :: ::ScrambleCortex)
- _жоден із варіантів не знайдено_ — 53 (напр. dialogs/characters/bigbret1/uk.xml :: =>a82)

РІШЕННЯ: **очки**; зверни увагу, що вказаний приклад "dialogs/characters/bigbret1/uk.xml :: =>a82" некоректний - він про вказання на щось, а не про чисельну характеристику

### stack

Сегментів із терміном у джерелі: **26**

- **стек** — 12 (knowledge/feats/uk.xml :: ::MagDump)
- **накопичення** — 5 (knowledge/feats/uk.xml :: ::MagDump)
- _жоден із варіантів не знайдено_ — 10 (напр. knowledge/caltrops/uk.xml :: ::BurrowerPoison)

РІШЕННЯ: **накопичення**

### psi ability

Сегментів із терміном у джерелі: **31**

- **псі здібність** — 16 (knowledge/combatstattooltips/uk.xml :: ::MetathermicsPsiCost)
- **псі-здібність** — 4 (knowledge/combatstattooltips/uk.xml :: ::ToGetPsiCritChanceMod)
- **психічна здібність** — 7 (knowledge/baseabilities/uk.xml :: ::GeneralInfo)
- **псі-здатність** — 1 (knowledge/enums/uk.xml :: ::PsiSchool.PsiAbility)
- _жоден із варіантів не знайдено_ — 3 (напр. knowledge/items/food/uk.xml :: ::coffee)

РІШЕННЯ: **псі-здібність**

### psionic

Сегментів із терміном у джерелі: **44**

- **псіонічний** — 11 (knowledge/enums/uk.xml :: ::PsiSchool.Psionic)
- **психічний** — 10 (knowledge/combatstattooltips/uk.xml :: ::Resolve)
- _жоден із варіантів не знайдено_ — 23 (напр. knowledge/combatstattooltips/uk.xml :: ::Psi)

РІШЕННЯ: **псіонічний**

### blueprint

Сегментів із терміном у джерелі: **11**

- **креслення** — 4 (knowledge/ui/uk.xml :: ::SystemBar_Crafting_Tooltip)
- **схема** — 7 (knowledge/itemblueprints/uk.xml :: ::supersoldierDrug)

РІШЕННЯ: **креслення**

### oddity

Сегментів із терміном у джерелі: **7**

- **диковина** — 6 (knowledge/rules/uk.xml :: ::oddityXp_Caption)
- **чудернацькі знахідки** — 1 (knowledge/enums/uk.xml :: ::Hotkey.OdditiesWindow)
- **дивні речі** — 1 (knowledge/rules/uk.xml :: ::oddityXp)

РІШЕННЯ: **диковина** я хотів би щоб застосовувалося до системи досвіду (що базується на знаходженні різних oddities) в цілому, але як панель інтерфейсу з переліком знахідок **чудернацькі знахідки** здається більш коректним. Залишаю на твій розсуд

### stealth

Сегментів із терміном у джерелі: **20**

- **непомітність** — 9 (knowledge/baseabilities/uk.xml :: ::Agility)
- **скрадання** — 11 (knowledge/feats/uk.xml :: ::S2)
- _жоден із варіантів не знайдено_ — 2 (напр. knowledge/itemblueprints/uk.xml :: ::cloakingDevice)

РІШЕННЯ: Потрібно розділити, бо **скрадання** - це процес, який залежить від навички **непомітність**

### constitution

Сегментів із терміном у джерелі: **10**

- **статура** — 9 (knowledge/baseabilities/uk.xml :: ::Constitution)
- **витривалість** — 2 (knowledge/baseabilities/uk.xml :: ::Constitution)

РІШЕННЯ: **статура**

### cold (тип шкоди)

Сегментів із терміном у джерелі: **12**

- **крижаний** — 5 (knowledge/combatstattooltips/uk.xml :: ::ResistanceCold)
- **холод** — 6 (knowledge/enums/uk.xml :: ::DamageType.Cold)
- _жоден із варіантів не знайдено_ — 1 (напр. knowledge/ui/uk.xml :: ::CombatStatsWindow_ColdResistance)

РІШЕННЯ: бажано **крижаний**, але потребує обмірковування, бо може трапитися десь явно ice/freezing, що викличе колізію

### heat (тип шкоди)

Сегментів із терміном у джерелі: **23**

- **тепловий** — 18 (knowledge/combatstattooltips/uk.xml :: ::ResistanceHeat)
- **тепло** — 1 (knowledge/enums/uk.xml :: ::DamageType.Heat)
- _жоден із варіантів не знайдено_ — 4 (напр. dialogs/characters/cc_moe/uk.xml :: =>q54)

РІШЕННЯ: **тепловий**

### character sheet

Сегментів із терміном у джерелі: **2**

- **лист персонажа** — 1 (knowledge/ui/uk.xml :: ::SystemBar_CharacterSheet)
- **характеристики персонажа** — 1 (knowledge/enums/uk.xml :: ::Hotkey.CharacterSheet)

РІШЕННЯ: **лист персонажа**

### veteran

Сегментів із терміном у джерелі: **4**

- **ветеран** — 3 (knowledge/rules/uk.xml :: ::dominatingDifficulty)
- **досвідчений** — 1 (knowledge/enums/uk.xml :: ::GameDifficulty.Normal)

РІШЕННЯ: **ветеран**, але GameDifficulty потребує узгодження також і для інших рівнів складності з цим новим стилем

### LMG / light machine gun

Сегментів із терміном у джерелі: **7**

- **легкий кулемет** — 3 (knowledge/itemblueprints/uk.xml :: ::lightMachineGun)
- **ручний кулемет** — 1 (knowledge/itemblueprints/uk.xml :: ::lightMachineGun_Name)
- **ЛК (скорочення)** — 3 (knowledge/feats/uk.xml :: ::FullAuto-XPHW)
- _жоден із варіантів не знайдено_ — 1 (напр. knowledge/feats/uk.xml :: ::MagDump)

РІШЕННЯ: **легкий кулемет** для light machine gun, **ЛК** для LMG

### SMG / submachine gun

Сегментів із терміном у джерелі: **12**

- **пістолет-кулемет** — 5 (knowledge/itemblueprints/uk.xml :: ::smg_Name)
- **ПК (скорочення)** — 7 (knowledge/feats/uk.xml :: ::KCS-Old)

РІШЕННЯ:  **пістолет-кулемет** для submachine gun, **ПК** для SMG

### cooldown

Сегментів із терміном у джерелі: **17**

- **відновлення** — 17 (knowledge/feats/uk.xml :: ::S2)
- **перезарядка** — 0 
- **відкат** — 0 

РІШЕННЯ: **відновлення**

### Corroded (дебаф)

Сегментів із терміном у джерелі: **2**

- **Корозія** — 1 (knowledge/traps/uk.xml :: ::CorrosiveAcidBlob)
- **Corroded (без перекладу)** — 1 (knowledge/items/utilities/uk.xml :: ::ThrowCorrosiveAcidVial)

РІШЕННЯ: **Корозія**

### Rig (локація)

Сегментів із терміном у джерелі: **2**

- **Платформа** — 1 (knowledge/maps/uk.xml :: ::RigPeriphery)
- **Ріг** — 1 (knowledge/deathscreen/uk.xml :: ::TheRig)

РІШЕННЯ: **Платформа**

### Temporal Manipulation

Сегментів із терміном у джерелі: **8**

- **Маніпуляція часом** — 4 (knowledge/enums/uk.xml :: ::SkillEnum.TemporalManipulation)
- **маніпулювання часом** — 4 (knowledge/combatstattooltips/uk.xml :: ::TemporalManipulationSkill)

РІШЕННЯ: **Маніпулювання часом**

### unarmed

Сегментів із терміном у джерелі: **21**

- **голіруч** — 19 (knowledge/baseabilities/uk.xml :: ::Dexterity)
- **голруч (одруківка)** — 1 (knowledge/combatstattooltips/uk.xml :: ::SpecialAttackBonusDamage)
- **голими руками** — 1 (knowledge/grenades/uk.xml :: ::Chemhaze)

РІШЕННЯ: **голіруч**

### Praetorian

Сегментів із терміном у джерелі: **3**

- **Praetorian (латиницею)** — 2 (dialogs/characters/cc_acidmessenger/uk.xml :: =>q5)
- **Преторіанці** — 1 (dialogs/characters/cc_jonthebeautiful/uk.xml :: =>q174)

РІШЕННЯ: **Praetorian**, як і для інших назв організацій

### Foundry (локація)

Сегментів із терміном у джерелі: **3**

- **Ливарня (велика — власна назва)** — 2 (knowledge/maps/uk.xml :: ::FoundryEntrance)
- **ливарня (мала — загальна назва)** — 1 (knowledge/maps/uk.xml :: ::Foundry)
- **Foundry (латиницею)** — 1 (knowledge/maps/uk.xml :: ::Foundry)

РІШЕННЯ: **Ливарня (велика — власна назва)**, але слід розрізняти Foundry Guard, які є фракцією

### Moe

Сегментів із терміном у джерелі: **4**

- **Moe (латиницею)** — 4 (dialogs/characters/cc_moe/uk.xml :: =>a49)
- **Мо (кирилицею)** — 0 

РІШЕННЯ: **Мо (кирилицею)**

### Drop Zone

Сегментів із терміном у джерелі: **1**

- **Drop Zone (латиницею)** — 1 (dialogs/characters/cc_moe/uk.xml :: =>q54)
- **Зона Скидання** — 0 

РІШЕННЯ: **Зона Скидання**

### Junkyard

Сегментів із терміном у джерелі: **12**

- **Звалище** — 11 (dialogs/characters/abram/uk.xml :: =>a7)
- **збирач мотлоху** — 1 (dialogs/characters/cc_al_fabet/uk.xml :: =>q2)

РІШЕННЯ: **Звалище**, але стосовно наведеного прикладу я не впевнений - не схоже що у рядку "Before you stands a man dressed as Junkyard." йшлося про локацію

### Black Sea

Сегментів із терміном у джерелі: **9**

- **Чорне Море (обидва з великої)** — 0 
- **Чорне море (родове з малої)** — 9 (knowledge/deathscreen/uk.xml :: ::BlisteringShoresResearchFacility)

РІШЕННЯ: **Чорне Море (обидва з великої)**

### dodge (у джерелі БЕЗ evasion)

Сегментів із терміном у джерелі: **3**

- **вивертання (правильно)** — 2 (knowledge/enums/uk.xml :: ::SkillEnum.Dodge)
- **ухилення (ПОМИЛКА — це Evasion)** — 1 (knowledge/items/food/uk.xml :: ::kzozelYantar)

РІШЕННЯ: **вивертання**

### Heavy Guns

Сегментів із терміном у джерелі: **2**

- **Важке озброєння** — 1 (knowledge/enums/uk.xml :: ::SkillEnum.HeavyGuns)
- **Важке озброння (одруківка)** — 1 (knowledge/enums/uk.xml :: ::SkillEnum.Heavy Guns)

РІШЕННЯ: **Важке озброєння**

### metathermic

Сегментів із терміном у джерелі: **9**

- **метатермічний** — 5 (knowledge/combatstattooltips/uk.xml :: ::MetathermicsSkill)
- **метермічний (одруківка)** — 3 (knowledge/combatstattooltips/uk.xml :: ::MetathermicsCritChance)
- _жоден із варіантів не знайдено_ — 1 (напр. knowledge/feats/uk.xml :: ::H)

РІШЕННЯ: **метатермічний**

