class WbtiType {
  WbtiType({
    required this.type,
    required this.title,
    required this.src,
    required this.name,
    required this.workStyle,
    required this.howToCoWork,
    required this.perfectMatchType,
  });

  final String type;
  final String title;
  final String src;
  final String name;
  final String workStyle;
  final String howToCoWork;
  final String perfectMatchType;

  static final List<WbtiType> wbtiTypeList = [enfj, enfp, entj, entp, esfj, esfp, estj, estp, infj, infp, intj, intp, isfj, isfp, istj, istp];
  static final List<WbtiType> wbtiTypeListByGanada = [esfp, intj, estp, esfj, estj, enfp, intp, isfj, entp, isfp, istj, entj, istp, enfj, infj, infp];

  static final WbtiType enfj = WbtiType(
    type: 'enfj',
    title: '카리스마 있는',
    src: 'assets/images/character/enfj.svg',
    name: '크런치 초콜릿',
    workStyle:
        '통찰력이 있고 영감을 주는 리더형인 ENFJ 유형은 사려 깊고 따뜻하며 창의적입니다. 이들은 언변이 능숙하며 사교적이기 때문에 동료 사이에서 인기가 많습니다. 이들은 말에 설득력이 있고, 따뜻한 카리스마로 조직 내에서 리더십을 발휘하는 스타일로써, 가지고 있는 탁월한 포용력을 발휘하여 공평한 팀 환경을 만들어 냅니다. 이 때문에 부하직원이나 동료가 잠재력을 발휘하는 데 큰 도움이 됩니다. 이들은 논리와 합리성보다는 직관과 감정에 더 많이 좌우되므로 주도적인 상황에서도 주변 사람들의 요구에 잘 공감합니다.',
    howToCoWork:
        'ENFJ 유형은 다른 사람들을 이끌고 돕는 것을 좋아하므로 조언과 헌신을 아끼지 않습니다. 특히 팀으로 협력할 때 자유로운 의견을 나누고 원활한 의사소통 능력을 보여주기 때문에 다른 사람들을 지원할 수 있는 환경에서 일할 때 이들은 빛을 발하게 됩니다. 다만 지나친 이상주의 때문에 팀원들의 한계를 인지하지 못하는 오류를 범하거나 비판에 대한 수용 능력이 부족할 수 있다는 점을 주의해야 합니다.',
    perfectMatchType: 'isfp',
  );

  static WbtiType enfp = WbtiType(
    type: 'enfp',
    title: '사교적인',
    src: 'assets/images/character/enfp.svg',
    name: '민트 초콜릿',
    workStyle:
        '활기차고 사교적인 ENFP 유형은 낙관적이고 외향적이며 창의성이 넘칩니다. 이들은 다양한 사회적 모임에서 모든 사람과 친구가 될 수 있을 만큼 사교적이며 호기심이 많고 뛰어난 대인기술을 보유하고 있습니다. 감정적으로 깊고 의미 있는 관계를 지향하기 때문에 논리보다는 감정에 따라 움직이는 편이며 다른 사람들에게 뛰어난 공감능력을 보여줍니다. 넘치는 에너지만큼 이들은 창의적인 지적 호기심을 자극하는 일에 강한 열정을 보이며 지도자의 역할을 수행할 때도 있지만, 어느 위치에 있든 공정하고 동등한 태도를 유지합니다.',
    howToCoWork:
        'ENFP 유형은 다른 사람들과 감정적으로 교류하며 함께 아이디어를 탐색하는 것을 좋아합니다. 다른 사람들의 의견과 제안을 경청하는 관용적인 태도를 지니고 있기 때문에 팀워크를 발휘하는 일을 할 때 빛이 납니다. 이들은 새로운 가능성과 일을 탐구하는 것을 좋아하기 때문에 일을 직관과 임기응변으로 처리하는 경향이 있고 지구력이 부족하여 일에 대한 흥미가 떨어지기 시작하면 끝맺음을 내기 어려울 때가 있기 때문에 주변의 격려와 응원이 큰 도움이 될 수 있습니다.',
    perfectMatchType: 'entp',
  );

  static WbtiType entj = WbtiType(
    type: 'entj',
    title: '무자비한 해결사',
    src: 'assets/images/character/entj.svg',
    name: '카라멜 초콜릿',
    workStyle:
        '타고난 지도자인 ENTJ 유형은 강경하고 거침없는 성격을 지니며 강한 자신감과 카리스마를 가지고 있습니다. 이들은 목표를 설정하고 성취하기 위해서는 효율성이 가장 중요하다고 생각하며 철저한 계획과 전략을 수립하는 능력이 뛰어납니다. 일을 해결할 때 감정보다는 냉철한 이성을 앞세우고 깔끔하고 정확하게 일을 처리하는 것이 중요하다고 생각합니다. 이들은 의지가 강하고 확고하므로 사람들이 비효율적이거나 무능력하다고 느껴질 때 참을성이 없고 매우 완고한 태도를 보여 주변으로부터 감정적인 비판을 받거나 갈등을 겪을 수도 있습니다.',
    howToCoWork:
        'ENTJ 유형은 원하는 것을 성취하고자 하는 열정과 실제로 일을 성공으로 이끄는 뛰어난 결단력, 지적능력을 보여줍니다. 다만 이들은 감정적 표현에 익숙하지 않을 뿐 아니라 때로는 과도한 자신감과 우월감 때문에 다른 사람의 의견을 고려하지 않는 모습을 보일 때가 있습니다. 성공은 결코 혼자만이 이뤄낼 수 있는 것이 아니라는 것을 유념한다면 더욱 의미 있고 만족스러운 결과를 얻어낼 수 있습니다.',
    perfectMatchType: 'infj',
  );

  static WbtiType entp = WbtiType(
    type: 'entp',
    title: '상상력이 풍부한',
    src: 'assets/images/character/entp.svg',
    name: '백년초 초콜릿',
    workStyle:
        '에너지가 넘치고 대담한 성격의 ENTP 유형은 지식이 풍부하고 유능한 사람으로 평가받습니다. 두뇌 회전이 빠르고 호기심이 강한 이들은 토론을 좋아하고 논쟁을 즐깁니다. 아이디어를 제시하는데 거리낌이 없고 많은 아이디어의 교류를 중요하게 생각하기 때문에 상호 간의 발전을 도모할 수 있습니다. 개방적이면서도 논리적인 모습으로 최선의 결과를 이루어 내지만 지나치게 논쟁적인 성격 때문에 주변인들과의 갈등이 발생하기도 합니다. 다행히도 천부적인 입담과 재치를 지니고 있기 때문에 이를 잘 활용하여 논쟁상황을 풀어가는 것이 좋습니다.',
    howToCoWork: 'ENTP 유형은 한계를 두거나 시키는 일에만 국한되는 것을 매우 싫어합니다. 새로운 아이디어에 대한 자유로운 토론과 의견 제시의 장을 열어둔다면 이들은 새로운 가치를 발견하고 객관적으로 평가하여 주변인들에게 큰 영감을 줄 수 있습니다. 다만 토론이나 논쟁의 상황에서 독설과 참견이 도를 넘는 것은 아닌지 주의할 필요가 있습니다.',
    perfectMatchType: 'enfp',
  );

  static WbtiType esfj = WbtiType(
    type: 'esfj',
    title: '배려가 넘치는',
    src: 'assets/images/character/esfj.svg',
    name: '마시멜로 초콜릿',
    workStyle:
        '긍정적인 에너지의 소유자인 ESFJ 유형은 친절하고 관대하며 이타적입니다. 이들은 사교적이며 개방적인 태도로 사람들은 한데 모으는 역할을 하며 다른 사람들의 필요를 먼저 생각하고 돕는 것을 좋아합니다. 법과 규칙, 질서와 체계를 중시하고  책임감이 강하기 때문에 다른 사람을 관리하는 일에 두각을 나타냅니다. 다만 옳고 그름에 대한 가치관이 명확하므로 자신과 다른 의견에 대해 수용하기 어려워하거나 비판과 거절을 잘 받아들이지 못하는 경향이 있습니다.',
    howToCoWork:
        'ESFJ 유형은 체계적인 질서 속에서 사람들과의 조화를 이루는 것을 좋아합니다. 자신을 필요로 하는 곳에 기꺼이 헌신할 수 있으며 많은 사람과 팀을 이루어 일을 완벽하게 수행해낼 때 큰 성취감을 느낍니다. 막중한 책임감 아래서 솔선수범하는 모습을 보이며 열심히 일하기 때문에 타의 귀감이 되지만 다른 사람들의 생각이나 행동을 모두 통제할 수 없다는 사실을 인정하고 타인의 거절이나 비판에도 의연하게 대처할 수 있는 능력을 길러야 합니다.',
    perfectMatchType: 'istj',
  );

  static WbtiType esfp = WbtiType(
    type: 'esfp',
    title: '흥이 넘치는',
    src: 'assets/images/character/esfp.svg',
    name: '감귤 초콜릿',
    workStyle:
        '긍정적인 웃음을 주고 열정이 넘치는 ESFP 유형은 활기차고 사교적이며 관찰력이 뛰어납니다. 사람들에게 관심받는 것을 좋아하고 좋은 분위기를 만들어내는데 탁월합니다. 이들은 열정과 즐거움을 추구하기 때문에 업무에서도 재미와 에너지를 찾는 방법을 알며 주변인들에게 활력을 불어넣어 줍니다. 또한, 공감능력과 관찰력이 뛰어나 어떠한 일이 발생했을 때 빠르게 파악하고 해결할 수 있습니다.',
    howToCoWork:
        'ESFP 유형은 혼자 일하는 것보다 많은 사람과 협력하는 일을 할 때 진가가 드러납니다. 사람들에게 활기를 불어넣고 조직 내에 갈등이 생기더라도 이를 해소시킬 수 있는 능력이 뛰어난데다 서로의 생각을 편하게 나눌 수 있기 때문에 긍정적인 분위기를 구축할 수 있습니다. 다만 즉흥적이고 자유로운 성격 탓에 일에 관한 책임을 등한시하는 일이 없도록 주의해야 합니다.',
    perfectMatchType: 'infp',
  );

  static WbtiType estj = WbtiType(
    type: 'estj',
    title: '근면성실한',
    src: 'assets/images/character/estj.svg',
    name: '말차 초콜릿',
    workStyle:
        '근면 성실하고 부지런한 ESTJ 유형은 정직하고 법과 질서를 중시합니다. 이들은 어렵고 힘든 상황에 앞장서고 최선의 결론을 내고자 노력하기 때문에 사람들이 무능력하거나 게으르고 부정직한 것을 용납하지 못합니다. 질서와 규칙을 만들어 잘 따르며 책임감을 가지고 주변 사람들을 자신의 방식대로 이끄는 리더십이 뛰어나서 어떤 위치에 있든 조직에 크게 이바지를 합니다. 다만 모든 사람이 같은 방식을 따르지는 않는다는 사실을 인정하고 개개인의 능력과 장점을 살릴 수 있는 새로운 방식에 대한 수용력이 필요합니다.',
    howToCoWork:
        'ESTJ 유형은 다른 사람들을 관리하고 조직하는 것을 좋아합니다. 규율에 어긋난 행동을 싫어하고 효율적인 일의 수행을 중시하기 때문에 원칙을 잘 지키고 정직하게 행동합니다. 때로는 지나치게 완고하여 주변 사람들에게 융통성이 없다는 얘기를 들을 수도 있지만, 효율성을 높이는 데 도움이 되는 비판과 논리적인 설명이 수반된다면 더 나은 발전을 위해 한 발짝 물러나는 모습을 보여줍니다.',
    perfectMatchType: 'isfj',
  );

  static WbtiType estp = WbtiType(
    type: 'estp',
    title: '도전적인',
    src: 'assets/images/character/estp.svg',
    name: '딸기 초콜릿',
    workStyle:
        '열정과 에너지가 가득한 ESTP 유형은 생각을 행동으로 바로 옮길 수 있는 행동력과 추진력이 강합니다. 이들은 정형화된 규칙이나 규율이 불필요하다고 생각되면 그것을 지키기보단 자신만의 새로운 규칙을 만들어 내는 등 변화를 두려워하지 않습니다. 또한, 현상을 있는 그대로 받아들이고 현재의 사실에 집중하기 때문에 문제 해결 능력이 뛰어납니다. 다만 너무 현재에만 치중하다가 다른 사람의 기분을 고려하지 못하거나 일이 잘못된 방향으로 흘러가지 않도록 주의해야 합니다.',
    howToCoWork: 'ESTP 유형은 안전하고 지루한 일보다 모험과 새로운 도전을 즐깁니다. 긴급상황이나 예기치 못한 일에 대한 문제 해결 능력이 뛰어나지만, 참을성이 부족하여 주의력이 분산될 위험이 있기 때문에 지속해서 흥미와 열정을 느낄 수 있는 분위기를 조성하는 것이 좋습니다.',
    perfectMatchType: 'intp',
  );

  static WbtiType infj = WbtiType(
    type: 'infj',
    title: '사려깊은',
    src: 'assets/images/character/infj.svg',
    name: '헤이즐넛 초콜릿',
    workStyle:
        '완벽주의적인 INFJ 유형은 조용하지만 사려 깊고 진솔합니다. 이들은 다른 사람들을 따뜻하게 돌보고 세심하게 신경 씁니다. 불평등하거나 불공평한 일을 맞닥뜨렸을 때 순응하기보다는 문제를 해결하기 위해 노력합니다. 희생정신이 강하고 양심적이기 때문에 다른 것들을 챙기느라 효율성이 떨어지는 경우가 있습니다. 하지만 원칙주의적이며 완벽함을 추구하기 때문에 자신이 맡은 일에 대한 책임감이 매우 강합니다.',
    howToCoWork:
        'INFJ 유형은 옳다고 믿는 것에 대한 추진력과 결단력이 뛰어납니다. 매우 양심적이며 확고한 가치관이 존재하기 때문에 어떤 일이든 최선을 다하고 그러한 상황에서 본인의 능력을 여실히 발휘합니다. 종종 이들의 생각과는 다른 방향으로 일이 진행 될 때 겉으로는 드러내지 않지만, 내면에서는 큰 괴리감을 느낄 수 있습니다. 이 때문에 때로는 혼자 일하면서 독립적인 시간이 부여되는 것이 좋습니다.',
    perfectMatchType: 'entj',
  );

  static WbtiType infp = WbtiType(
    type: 'infp',
    title: '조화로운',
    src: 'assets/images/character/infp.svg',
    name: '화이트 초콜릿',
    workStyle:
        '조용하지만 열정이 넘치는 INFP 유형은 상상력과 감수성이 풍부합니다. 이들은 공감 능력이 매우 높아서 사람들의 감정이나 사고방식을 쉽게 파악하고 도움을 주고 싶어 합니다. 상냥한 성격 덕분에 주변 사람들의 인정을 받고 감정적으로 유대감이 깊은 관계를 잘 구축할 수 있습니다. 또한, 뛰어난 상상력 덕분에 항상 아이디어가 넘치고 그 아이디어를 모든 사람이 동등한 위치에서 자유롭게 공유하는 것을 좋아합니다. 다만 몽상에 지나치게 집중하다가 실제로 행동에 옮기지 못하거나 마감기한을 준수하지 못하는 일이 발생하지 않도록 주의해야 합니다.',
    howToCoWork:
        'INFP 유형은 다른 사람에게 진정한 도움이 되기를 원합니다. 어떤 상황에서도 정직하고 올바른 일을 하도록 노력하고 화합과 조화를 유지하기 위해 많은 에너지를 쏟습니다. 솔직하면서도 친절한 소통방식은 주변 사람들을 편하게 만들어주는 힘이 있습니다. 부정적이거나 비판적인 태도보다는 긍정적인 피드백과 칭찬이 이들의 능력을 더욱 끌어 올려 줄 수 있습니다. 하지만 일의 효율성과 완벽한 마무리를 위해 때로는 필요한 비판을 제기하는 연습이 필요합니다.',
    perfectMatchType: 'esfp',
  );

  static WbtiType intj = WbtiType(
    type: 'intj',
    title: '전략적인',
    src: 'assets/images/character/intj.svg',
    name: '다크 초콜릿',
    workStyle:
        '독립적이고 이성적인 INTJ 유형은 두뇌 회전이 빠르고 논리적입니다. 이들은 지식을 확장하고 지적 능력을 발달시키는 것을 좋아하기 때문에 무의미한 사교활동에 많은 시간을 보내지 않습니다. 또한, 독립적인 성향이 두드러져 팀워크를 발휘하는 일보다는 혼자 일하는 것을 선호하고 높은 집중력을 가지고 있기 때문에 좋은 결과를 만들어 냅니다. 다만 지나치게 솔직하거나 비판적일 때가 있어 사람들에게 오만하거나 무례한 사람으로 오해받지 않도록 주의해야 합니다.',
    howToCoWork:
        'INTJ 유형은 어떠한 일이든 성공적으로 해낼 수 있다는 자신감이 있습니다. 뛰어난 결단력으로 빠르게 결정을 내리고 일을 처리할 수 있습니다. 능동적으로 행동하고 전문적이고 논리적인 의견을 제시하면 누구보다 훌륭한 협력자로서 함께 일을 수행할 수 있습니다. 다만 독단적으로 행동하거나 다른 사람의 의견을 무시하는 일이 없도록 다른 사람을 배려하는 마음을 키운다면 더욱 큰 성공을 거둘 수 있다는 것을 항상 기억해야 합니다.',
    perfectMatchType: 'istp',
  );

  static WbtiType intp = WbtiType(
    type: 'intp',
    title: '뛰어난 괴짜',
    src: 'assets/images/character/intp.svg',
    name: '밀크 초콜릿',
    workStyle: '상상력과 호기심이 넘치는 INTP 유형은 분석하는 것을 좋아하고 논리적입니다. 창의적인 생각을 많이 하고 아이디어가 넘쳐나기 때문에 복잡한 문제에 대한 해결책도 쉽게 낼 수 있는 능력이 있습니다. 이들은 논리와 이성을 중시하고 패턴과 경향을 분석하는 것을 좋아하기 때문에 정서적 신호에는 무감각할 수 있습니다.',
    howToCoWork: 'INTP 유형은 지적 자극을 받을 수 있는 독립적인 환경을 선호합니다. 경직된 구조보다는 자유롭지만, 결과에 관한 책임이 부여되는 환경 속에서 그 누구보다 효과적인 결과를 이끌어 낼 수 있습니다.',
    perfectMatchType: 'estp',
  );

  static WbtiType isfj = WbtiType(
    type: 'isfj',
    title: '듬직한',
    src: 'assets/images/character/isfj.svg',
    name: '바나나 초콜릿',
    workStyle:
        '헌신적이고 섬세한 ISFJ유형은 주변에 지원을 아끼지 않고 배려심이 넘칩니다. 이들은 세심한 관찰력과 분석력을 가지고 있으면서 동시에 대인관계 능력도 뛰어나기 때문에 집단 속에서 중요한 역할을 합니다. 경쟁보다는 조화와 협력을 도모하고 다른 사람을 돕는 것을 좋아하는 이타주의자입니다. 다만 지나친 요구에 대해 거절하는 방법을 배우고 이들의 겸손함과 배려심을 악용하는 사람들을 분별할 수 있는 능력을 키우는 것이 좋습니다.',
    howToCoWork:
        'ISFJ 유형은 도움을 주는 것을 좋아하고 강한 책임감과 의무감을 가지고 있습니다. 어떠한 일이든 진지한 태도로 임하고 기대에 부응하는 결과를 만들어 냅니다. 혼자 일하는 것보다 공동의 목표를 향해 함께 협력하는 것을 선호하고 그 과정에서 이들의 이타적인 성향이 주변에 긍정적인 에너지를 전달합니다. 대부분 도움을 주는 입장이지만 효율적인 일의 진행을 위해 필요할 때는 도움을 요청할 줄 알아야 합니다.',
    perfectMatchType: 'estj',
  );

  static WbtiType isfp = WbtiType(
    type: 'isfp',
    title: '따뜻한 감성의',
    src: 'assets/images/character/isfp.svg',
    name: '블루베리 초콜릿',
    workStyle:
        '자유로운 영혼의 ISFP 유형은 친절하고 따뜻한 감성을 지니고 있습니다. 이들은 열정적이고 새로운 것에 대한 호기심이 많으며 예술가적인 성향을 가지고 있기 때문에 엄격하게 관리되거나 통제받는 환경을 좋아하지 않습니다. 특유의 여유롭고 유연한 태도와 뛰어난 상황대처 능력으로 주변으로부터 긍정적인 평가를 받습니다. 다만 장기적인 계획성이 부족할 수 있기 때문에 목표를 명확하게 설정하고 지치지 않도록 적절히 관리하는 것이 중요합니다.',
    howToCoWork:
        'ISFP 유형은 행동력이 좋고 융통성이 뛰어납니다. 이 때문에 다양한 일에 열정을 가지면서도 한 가지 일에 완벽하게 몰입할 수 있는 능력을 보여줍니다. 과도하게 통제되기보다 개방적인 환경에서 잠재력을 더욱 발휘하고 현재 얻을 수 있는 최선의 결과를 이끌어 내게 됩니다. 이들은 보통 지배적으로 관리하는 위치보다는 동등하게 협력하는 것을 선호하지만 지나친 상호 작용이 필요한 경우 쉽게 지칠 수 있기 때문에 개인적인 시간을 부여해야 합니다.',
    perfectMatchType: 'enfj',
  );

  static WbtiType istj = WbtiType(
    type: 'istj',
    title: '현실적인',
    src: 'assets/images/character/istj.svg',
    name: '아몬드 초콜릿',
    workStyle:
        '조용하고 솔직한 ISTJ 유형은 책임감이 강하고 현실적입니다. 이들은 체계와 질서를 중시하고 책임감에 대한 엄격한 기준이 있기 때문에 정해진 절차를 철저하게 따르고 주어진 임무를 기한 내에 수행합니다. 또한, 현실 감각이 뛰어나기 때문에 상황을 객관적으로 판단할 수 있고 스트레스로부터 비교적 자유롭습니다. 다만 융통성이 부족하여 지나치게 엄격하다는 평가를 받거나 대인관계에 어려움이 생기지 않도록 주의해야 합니다.',
    howToCoWork:
        'ISTJ 유형은 정직하고 부지런하게 자신의 의무를 다합니다. 이들은 즉흥적인 상황보다는 안전하고 체계적인 메뉴얼을 따르는 것을 좋아하기 때문에 명확한 목표와 역할을 제시해 주는 것이 좋습니다. 함께 협력하는 일보다는 혼자 일 할 때 보다 높은 만족감을 느끼지만 때로는 다른 사람들이 본인의 잣대에 충족하지 못하여도 포용할 수 있는 능력을 기른다면 함께 하는 즐거움을 얻을 수 있습니다.',
    perfectMatchType: 'esfj',
  );

  static WbtiType istp = WbtiType(
    type: 'istp',
    title: '즉흥적인',
    src: 'assets/images/character/istp.svg',
    name: '쿠엔크 초콜릿',
    workStyle:
        '조용하고 내성적인 ISTP 유형은 호기심과 탐구심이 강합니다. 새로운 시도를 하는 것을 좋아하고 직접 시행착오를 겪고 몸소 체감하는 열정을 가지고 있습니다. 이들은 대우받고 싶은 대로 대우하기 때문에 남들에게 관대하고 개방적인 모습을 보이는 한편 독립적인 공간이 보장되어야 하고 자유를 침해받는 것을 싫어합니다. 이들은 합리적이면서도 즉흥적이기 때문에 다음에 무엇을 할지 예측하기 힘든 경향이 있기 때문에 너무 산만해질 수 있다는 점을 주의해야 합니다.',
    howToCoWork: 'ISTP 유형은 억압받지 않고 공정한 환경 속에서 진가를 발휘합니다. 이들은 새로운 일에 대한 두려움이 없고 거침없이 시도할 수 있습니다. 다만 꾸준하게 헌신하거나 집중하는 능력이 부족할 수 있기 때문에 주의가 필요합니다.',
    perfectMatchType: 'intj',
  );

  static WbtiType getType(String type) {
    switch (type) {
      case 'enfj':
        return WbtiType.enfj;
      case 'enfp':
        return WbtiType.enfp;
      case 'entj':
        return WbtiType.entj;
      case 'entp':
        return WbtiType.entp;
      case 'esfj':
        return WbtiType.esfj;
      case 'esfp':
        return WbtiType.esfp;
      case 'estj':
        return WbtiType.estj;
      case 'estp':
        return WbtiType.estp;
      case 'infj':
        return WbtiType.infj;
      case 'infp':
        return WbtiType.infp;
      case 'intj':
        return WbtiType.intj;
      case 'intp':
        return WbtiType.intp;
      case 'isfj':
        return WbtiType.isfj;
      case 'isfp':
        return WbtiType.isfp;
      case 'istj':
        return WbtiType.istj;
      case 'istp':
        return WbtiType.istp;
      default:
        return WbtiType.enfj;
    }
  }
}
