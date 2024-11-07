class WbtiQuestion {
  int type;
  String question1;
  String question2;

  static const int wbtiTypeE = 1;
  static const int wbtiTypeI = 2;
  static const int wbtiTypeS = 3;
  static const int wbtiTypeN = 4;
  static const int wbtiTypeT = 5;
  static const int wbtiTypeF = 6;
  static const int wbtiTypeJ = 7;
  static const int wbtiTypeP = 8;

  WbtiQuestion({required this.type, required this.question1, required this.question2});

  static List<WbtiQuestion> wbtiQuestionList = [
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeE,
      question1: '회사에 새로 들어온 사람에게',
      question2: '적극적으로 다가간다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeI,
      question1: '사수에게 업무질문을',
      question2: '하는게 어렵다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeI,
      question1: '프로젝트 리더 역할을 맡는 일은',
      question2: '가능한 피하고 싶다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeI,
      question1: '추진하던 일이 난관에 부딪혔을 때 다른 구성원에게',
      question2: '조언을 구하기보단 혼자 고민하는 편이다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeE,
      question1: '우리 팀 업무와 관련된 새로운 트렌드 기사를 접했을',
      question2: '때 팀원들과 함께 볼 수 있도록 공유하는 편이다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeN,
      question1: '평소 다른 직무가 어떤 일을',
      question2: '하는지 궁금하다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeS,
      question1: '자율적인 업무보단 규칙이',
      question2: '정해진 업무가 더 편하다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeN,
      question1: '이전의 성공 경험 데이터 보다는 현재의 직감 및',
      question2: '트렌드가 더 중요하다고 생각한다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeS,
      question1: '새로운 프로젝트에 대한 상상과 아이디어',
      question2: '때문에 흥분하는 일은 없다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeN,
      question1: '자유롭고 성장할 수 있는 환경이',
      question2: '연봉의 액수보다 중요하다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeF,
      question1: '고객을 대할 때 기술보다',
      question2: '정성이 더 중요하다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeF,
      question1: '다른 직무의 업무적인 고충에',
      question2: '쉽게 공감할 수 있다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeF,
      question1: '직장 동료와의 의견 차이가 있을 때 상대의 입장을',
      question2: '이해하기 위해 노력을 많이 하는 편이다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeT,
      question1: '회의 중 논쟁에서 이기는 것이 상대방을',
      question2: '불쾌하지 않도록 하는 것보다 더 중요하다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeT,
      question1: '협업을 하는 경우 팀워크보다',
      question2: '업무 효율이 더 중요하다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeJ,
      question1: '하나의 업무를 완전히 끝낸 후',
      question2: '다른 업무를 시작하는 편이다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeP,
      question1: '스케줄이 계획되어 있을 때 갑작스러운',
      question2: '회의가 잡혀도 괜찮은 편이다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeJ,
      question1: '마감 전에 여유롭게',
      question2: '일을 끝내는 편이다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeP,
      question1: '결정을 내리는 일을 마지막까지',
      question2: '미루는 편이다.',
    ),
    WbtiQuestion(
      type: WbtiQuestion.wbtiTypeJ,
      question1: '연차 계획은 철저하게',
      question2: '세우는 편이다.',
    ),
  ];

  static List<WbtiQuestion> getRandomQuestionList(){
    List<WbtiQuestion> result = wbtiQuestionList;
    result.shuffle();
    return result;
  }
}


