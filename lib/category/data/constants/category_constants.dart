import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CategoryConstants {
  static const Map<String, ({IconData icon, List<String> keywords})>
  incomeCategories = {
    'bonus': (
      icon: PhosphorIconsRegular.gift,
      keywords: ['حوافز', 'بونص', 'bonus'],
    ),
    'salary': (
      icon: PhosphorIconsRegular.money,
      keywords: ['مرتب', 'المرتب', 'قبضت', 'salary', 'income'],
    ),
    'freelance': (
      icon: PhosphorIconsRegular.briefcase,
      keywords: ['يومية', 'freelance'],
    ),
    'refund': (
      icon: PhosphorIconsRegular.arrowCounterClockwise,
      keywords: ['استرجاع', 'refund'],
    ),
    'cashback': (
      icon: PhosphorIconsRegular.handCoins,
      keywords: ['كاش باك', 'cashback'],
    ),
    'profits': (
      icon: PhosphorIconsRegular.chartLineUp,
      keywords: ['ارباح', 'مكسب', 'profits', 'profit', 'فوايد', 'كسبت'],
    ),
    'investments': (
      icon: PhosphorIconsRegular.bank,
      keywords: ['استثمار', 'investments'],
    ),
    'gameaya': (
      icon: PhosphorIconsRegular.usersThree,
      keywords: ['جمعية', 'الجمعية', 'استلمت الجمعية', 'ربح'],
    ),
    'instapay': (
      icon: PhosphorIconsRegular.lightning,
      keywords: [
        'انستاباي',
        'instapay',
        'اضافه تحويل لحظى',
        'إضافة تحويل لحظي',
        'instant pay',
        'instantpay',
      ],
    ),
    'other': (icon: PhosphorIconsRegular.dotsThree, keywords: ['other']),
  };

  static const Map<String, ({IconData icon, List<String> keywords})>
  expenseCategories = {
    'food': (
      icon: PhosphorIconsRegular.forkKnife,
      keywords: [
        'مطعم',
        'اكل',
        'فطار',
        'عشا',
        'غدا',
        'وجبه',
        'سندوتشات',
        'سندوتش شاورما',
        'سندوتش كريب',
        'سندوتش سجق',
        'سندوتش حواوشي',
        'سندوتش كبده',
        'سندوتش بطاطس',
        'سندوتش فول',
        'سندوتش طعميه',
        'سندوتش برجر',
        'كريب',
        'فول',
        'طعميه',
        'بطاطس',
        'بطاطس سوري',
        'سجق',
        'كبده',
        'كفته',
        'حواوشي',
        'فراخ',
        'لحمة',
        'لحمه',
        'سمك',
        'رومي',
        'سوري',
        'وهمي',
        'رشدي',
        'ماكس',
        'بريمر',
        'ماك',
        'ماك دونالد',
        'ك اف سي',
        'كيكرز',
        'شيكرز',
      ],
    ),
    'transportation': (
      icon: PhosphorIconsRegular.bus,
      keywords: ['مترو', 'سرفيس', 'مكروباص', 'مواصلات', 'باص', 'اتوبيس'],
    ),
    'fuel': (icon: PhosphorIconsRegular.gasPump, keywords: ['بنزين', 'fuel']),
    'apple_pay': (
      icon: PhosphorIconsRegular.appleLogo,
      keywords: ['applepay', 'apple pay', 'ابل باي', 'ابلباي'],
    ),
    'instapay': (
      icon: PhosphorIconsRegular.lightning,
      keywords: [
        'انستاباي',
        'instapay',
        'تنفيذ تحويل لحظى',
        'تنفيذ تحويل لحظي',
        'instant pay',
        'instantpay',
      ],
    ),
    'telda': (
      icon: PhosphorIconsRegular.creditCard,
      keywords: ['تيلدا', 'telda'],
    ),
    'vodafone_cash': (
      icon: PhosphorIconsRegular.wallet,
      keywords: ['فودافون كاش', 'فودافون', 'vodafone cash'],
    ),
    'e_and_pay': (
      icon: PhosphorIconsRegular.wallet,
      keywords: ['اتصالات كاش', 'اتصالات', 'e&pay'],
    ),
    'we_pay': (
      icon: PhosphorIconsRegular.wallet,
      keywords: ['وي كاش', 'وي', 'wepay'],
    ),
    'education': (
      icon: PhosphorIconsRegular.graduationCap,
      keywords: ['كشكول', 'كراسه', 'قلم', 'مسطره', 'education'],
    ),
    'health': (icon: PhosphorIconsRegular.firstAid, keywords: ['health']),
    'entertainment': (
      icon: PhosphorIconsRegular.gameController,
      keywords: ['دبدوب', 'كوره', 'حجز كوره', 'entertainment'],
    ),
    'home': (
      icon: PhosphorIconsRegular.house,
      keywords: ['طلبات البيت', 'برواز', 'كاتل', 'home'],
    ),
    'personal_care': (
      icon: PhosphorIconsRegular.sparkle,
      keywords: [
        'شاور gel',
        'شاور',
        'كريم',
        'فوطه',
        'فرشه اسنان',
        'معجون',
        'شامبو',
        'صابون',
        'كريم شعر',
        'معطر',
        'فواحه',
        'مشط',
        'personalcare',
      ],
    ),
    'shopping': (
      icon: PhosphorIconsRegular.shoppingBag,
      keywords: [
        'جبت',
        'اشتريت',
        'هدوم',
        'طرحه',
        'سلسله',
        'خاتم',
        'بلوزه',
        'تيشيرت',
        'بنطلون',
        'شورت',
        'حلق',
        'نضاره',
        'هودي',
        'shopping',
      ],
    ),
    'subscriptions': (
      icon: PhosphorIconsRegular.deviceMobile,
      keywords: ['فاتورة نت', 'فاتوره النت', 'نت', 'subscriptions'],
    ),
    'travel': (
      icon: PhosphorIconsRegular.airplane,
      keywords: ['سفر', 'travel'],
    ),
    'utilities': (
      icon: PhosphorIconsRegular.lightbulb,
      keywords: [
        'فاتورة كهربا',
        'فاتورة ميه',
        'فاتورة غاز',
        'فواتير',
        'مايه',
        'غاز',
        'كهربا',
        'utilities',
      ],
    ),
    'work': (
      icon: PhosphorIconsRegular.briefcase,
      keywords: ['ورك اسبيس', 'work'],
    ),
    'outing': (
      icon: PhosphorIconsRegular.beerBottle,
      keywords: ['خروج', 'خروجات', 'outing'],
    ),
    'coffee_shop': (
      icon: PhosphorIconsRegular.coffee,
      keywords: [
        'قهوه',
        'نسكافيه',
        'كافيه',
        'شاي',
        'قهوه فرنسي',
        'اسبريسو',
        'لاتيه',
        'كابتشينو',
        'مج',
        'coffee shop',
      ],
    ),
    'smoking': (
      icon: PhosphorIconsRegular.cigarette,
      keywords: [
        'سجاير',
        'ولاعه',
        'ليكود',
        'بود',
        'كارتدج',
        'smoking',
        'ال ام',
      ],
    ),
    'debts': (
      icon: PhosphorIconsRegular.handshake,
      keywords: ['استلفت', 'دين', 'قسط', 'قسطت', 'debts'],
    ),
    'rent': (icon: PhosphorIconsRegular.key, keywords: ['ايجار', 'rent']),
    'investments_expense': (
      icon: PhosphorIconsRegular.chartLineUp,
      keywords: ['تحويشة', 'investments'],
    ),
    'mobile': (
      icon: PhosphorIconsRegular.deviceMobile,
      keywords: ['فون', 'تليفون', 'ايفون', 'رصيد', 'سماعه', 'شاحن'],
    ),
    'groceries': (
      icon: PhosphorIconsRegular.shoppingCart,
      keywords: [
        'سوبر ماركت',
        'خضار',
        'لبن',
        'جبنه',
        'شيبسي',
        'شيكولاته',
        'مكرونه',
        'زيت',
        'سمنه',
        'رز',
        'عدس',
        'كاتشب',
        'مايونيز',
        'ملح',
        'سكر',
      ],
    ),
    'gameaya_expense': (
      icon: PhosphorIconsRegular.usersThree,
      keywords: ['جمعية', 'الجمعية', 'قسط الجمعية'],
    ),
    'other': (
      icon: PhosphorIconsRegular.dotsThree,
      keywords: ['حجز', 'كارته', 'سعر', 'other'],
    ),
  };

  static const Map<String, ({IconData icon, List<String> keywords})>
  transferCategories = {
    'atm_withdrawal': (
      icon: PhosphorIconsRegular.money,
      keywords: [
        'سحبت',
        'سحب',
        'atm_withdrawal',
        'withdrew',
        'withdraw',
        'withdrawal',
      ],
    ),
    'credit_card_settlement': (
      icon: PhosphorIconsRegular.creditCard,
      keywords: ['سددت', 'settlement'],
    ),
    'transfer': (
      icon: PhosphorIconsRegular.arrowsLeftRight,
      keywords: [
        'حولت',
        'تحويل',
        'نقلت',
        'transfer',
        'بعت',
        'تحويل من',
        'اتحولي',
        'حولي',
      ],
    ),
  };
}
