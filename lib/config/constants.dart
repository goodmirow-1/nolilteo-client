import 'package:flutter/material.dart';

const int nullInt = -100;
const kPrimaryColor = Colors.blue;
const Color nolColorOrange = Color(0xFFFF8B77);
const Color nolColorBlack = Color(0xFF2A2E37);
const Color nolColorLightGrey = Color(0xFFEEEEEE);
const Color nolColorGrey = Color(0xFFBBBBBB);
const Color nolColorRed = Color(0xFFED4040);

const List<String> reportList = [
  '광고 및 홍보성 글이에요',
  '욕설이나 비방 또는 성희롱이 포함된 글이에요.',
  '도배된 글이에요.',
  '주제와 맞지 않는 글이에요.',
  '혐오감이나 불쾌감을 주는 글이에요.',
  '명예훼손 및 저작권 침해가 포함된 글이에요.',
  '부적절한 만남을 유도하는 글이에요.',
  '본인 또는 타인의 개인정보가 노출된 글이에요.',
  '기타',
];

const List<String> userReportList = [
  '광고 및 홍보성 글을 올려요.',
  '욕설이나 비방 또는 성희롱을 해요.',
  '게시글이나 댓글을 도배해요.',
  '혐오감이나 불쾌감을 주는 글을 올려요.',
  '명예훼손 및 저작권 침해를 해요.',
  '부적절한 만남을 유도하는 글을 올려요.',
  '본인 또는 타인의 개인정보를 노출해요.',
  '기타',
];

const List<String> userExitReportList = [
  '렉이 걸리거나 속도가 느린 일이 잦게 일어나요.',
  '다른 대체할만한 커뮤니티 서비스를 발견했어요',
  '다른 계정으로 다시 가입할거에요.',
  '새로운 글이 잘 안올라오거나 마음에 드는 글이\n없어요.',
  '너무 많이 이용해요',
  '비매너 이용자가 많아요.',
  '이용방법이 어려워요.',
  '오류가 자주 발생해요.',
  '기타'
];

const List<String> jobCategoryList = [
  '프로그래머/개발직',
  '디자이너',
  '기획/전략/경영직',
  '법률/법무직',
  '인사/노무직',
  '재무/회계/세무직',
  '비서/수행직',
  '외국어/통역직',
  '구매/자재직',
  '상품기획/MD',
  '물류/운송',
  '영업/제휴직',
  '요식/영양/제빵',
  '정비/기술직',
  '경호/보안직',
  '체육/스포츠직',
  '여행/항공/숙박',
  '뷰티/미용직',
  '복지/요양',
  '서비스직',
  '마케터/홍보',
  '연구개발/설계',
  '공정/품질관리',
  '생산/제조',
  '교사/강사/교육직',
  '의료/보건직',
  '예술/방송직',
  '시행/시공/건축',
  '농/어/임/광부',
  '금융/보험',
  '상담직',
  '기타 전문/특수직',
  '자영업',
  '프리랜서',
  '공무원',
  '알바/일용직',
];

const List<String> topicCategoryList = [
  '자유',
  '유머',
  '연애',
  '회사생활',
  '재테크/부동산',
  '시사/경제',
  '봉사활동',
  '반려동물/식물',
  '생활/자취',
  '결혼/육아',
  '아웃도어/여행',
  '운동/레저스포츠',
  '댄스/무용',
  '게임/만화/키덜트',
  '문화/공연/예술',
  '책/글',
  '음악/악기',
  '요리/제빵/음료',
  '공예/만들기',
  'TV/연예',
  '패션/뷰티',
  '쇼핑/맛집',
  '차량/탈것',
  '사진/영상',
  'PC/전자제품',
  '시험/자격증',
  '외국어/언어',
];

const int blindCount = 5; // 블라인드 되는 수
const String blindSentence = '신고 누적으로 블라인드 된 글 입니다.';

const int deleteTypeShow = 0; // 삭제 x
const int deleteTypeUser = 1; // 유저에 의해 삭제
const int deleteTypeAdmin = 2; // 관리자에 의해 삭제

const int interestMaxNum = 10; // 관심사 최대 개수
const int popularLimit = 4; // 인기 게시글 최대 개수

const double webMaxWidth = 532; // 웹 최대 너비

const String urlTermsOfService = 'https://www.sheeps.kr/nolilteo/legal/user-agreement';
const String urlPrivacyPolicy = 'https://www.sheeps.kr/nolilteo/legal/privacy-policy';
const String urlInstagram = 'https://www.instagram.com/jaegong_gamyu/';
const String urlMarketingTerms = 'https://www.sheeps.kr/nolilteo/legal/marketing-agreement';
