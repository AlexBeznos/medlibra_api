# frozen_string_literal: true

require "oj"
require_relative "../system/boot"
require_relative "../system/medlibra/import"

class Filler
  FIELDS_MAPPER = {
    "загальна лікарська підготовка" => "Лікувальна справа",
  }.freeze

  SUBFIELDS_MAPPER = {
    "паталогічна анатомія" => "Патологічна анатомія",
    "паталогічна фізіологія" => "Патологічна фізіологія",
    "фізколоїдна хімія" => "Фізична та колоїдна хімія",
    "атл" => "Аптечна технологія ліків",
    "зтл" => "Заводська технологія ліків",
    "ммф" => "Менеджмент та маркетинг у фармації",
    "оеф" => "Організація та економіка фармації",
    "допомога та що потребує особливої тактики" => "Допомога, що потребує особливої тактики",
    "надання допомоги та та профілактики" => "Надання допомоги та профілактики",
    "організація допомоги та в т.ч. профілактики" => "Організація надання допомоги та профілактика",
    "організація надання допомоги" => "Організація надання допомоги та профілактика",
    "повторне (лікування та що триває)" => "Повторне відвідування",
    "військо-медична підготовка" => "Військово-медична підготовка",
    "гінекологія та репр. здоров'я. 2" => "Гінекологія та репр. здоров'я",
    "догляд за хворими та маніп. тех." => "Догляд за хворими та маніпуляційна техніка",
    "епідеміологія з медичною паразитологією" => "Епідеміологія та паразитологія",
    "охорона праці" => "Основи охорони праці",
    "соціальна медицина та ооз" => "Соціальна медицина та організація охорони здоров’я",
    "соцмедицина та організація охорони здоров’я" => "Соціальна медицина та організація охорони здоров’я",
    "гістологія та цитологія та ембріологія" => "Гістологія, цитологія та ембріологія",
    "мікробіологія та вірусологія та імунологія" => "Мікробіологія,  вірусологія та імунологія",
    "орг.-упр. діяльність" => "Організаційно-управлінська діяльність",
    "біологічна хімія" => "Біохімія",
    "ботаніка" => "Фармацевтична ботаніка",
    "технологія парфумерно-косметичних засобів" => "Косметологія",
    "aптечна техніка лікарських та косметичних препаратів" => "Аптечна технологія лікарських та косметичних препаратів",
    "менеджмент та маркетинг в галузі" => "Менеджмент та маркетинг косметології",
    "організація та економіка в галузі" => "Організація та економіка косметології",
    "технологія парфумерно-косметичних засобів промислового виробництва" => "Промислове виробництво парфумерно-косметичних засобів",
    "загальна лікарська підготовка" => "Лікувальна справа",
    "акушерство і гінекологія" => "Акушерство та гінекологія",
    "гігієна, ооз" => "Гігієна та ООЗ",
    "педіатричний профіль" => "Педіатрія",
    "наркологія" => "Психіатрія та наркологія",
    "менеджмент та маркетинг у фармації" => "Менеджмент та маркетинг фармації",
    "акушерсько-гінекологічний профіль" => "Акушерство та гінекологія",
    "інфекційний профіль" => "Інфекційні хвороби",
    "терапевтичний профіль" => "Терапія",
    "хірургічний профіль" => "Хірургія",
    "допомога стоматологічним хворим, що потребують особливої тактики" => "Допомога хворим, які потребують особливої тактики",
    "надання допомоги та профілактики" => "Надання допомоги та профілактика",
    "акушерство" => "Акушерська справа",
    "гінекологія та репр. здоров'я" => "Гінекологія та репродуктивне здоров'я",
    "гінекологія. репродуктивне здоров'я сім’ї" => "Гінекологія та репродуктивне здоров'я",
    "загальний догляд за хворими" => "Догляд за хворими та медична маніпуляційна техніка",
    "клінічні лаб. дослідження" => "Клінічні лабораторні дослідження",
    "нc в акушерстві" => "Невідкладні стани в акушерстві та гінекології",
    "нc в педіатрії" => "Невідкладні стани в педіатрії",
    "нc в хірургії" => "Невідкладні стани в хірургії",
    "нc у внутрішній медицині" => "Невідкладні стани у внутрішній медицині",
    "педіатрія" => "Педіатрія та дитячі інфекції",
    "предмети терапевт.профілю" => "Терапія",
    "предмети хірург.профілю" => "Хірургія",
    "медпрофілактика" => "Медична профілактика",
    "аналітична хімія з тех. лаб. робіт" => "Аналітична хімія",
    "комун. гігієна з осн. сан. справи" => "Комунальна гігієна",
    "соціальна медицина та основи охорони здоров’я" => "Соціальна медицина та ООЗ",
    "сестринство" => "Сестринська справа",
    "медсестринство в акушерстві" => "Акушерство",
    "медсестринство в гінекології" => "Гінекологія",
    "нс в терапії" => "Невідкладні стани в терапії",
    "нc в терапії" => "Невідкладні стани в терапії",
    "терапевтичний" => "Терапія",
  }.freeze
  include Medlibra::Import[
    "repositories.kroks_repo",
    "repositories.fields_repo",
    "repositories.years_repo",
    "repositories.subfields_repo",
    "repositories.assessments_repo",
    "repositories.questions_repo",
    "repositories.answers_repo",
    "repositories.assessment_questions_repo",
  ]

  def call(data)
    return if data["subField"].first.to_s.match(/USMLE/)
    return if data["questions"].empty?

    krok = find_or_create_krok(data["krokType"])
    field = find_or_create_field(data["field"], krok)
    year = find_or_create_year(data["year"])
    subfield_name = data["subField"].first

    if subfield_name
      subfield = find_or_create_subfield(
        find_name(
          prep_subfield(subfield_name),
          SUBFIELDS_MAPPER,
        ),
      )
    end

    make_assessment_for(
      krok: krok,
      field: field,
      subfield: subfield,
      year: year,
      type: data["testType"],
      questions: data["questions"],
    )
  end

  private

  def make_assessment_for(krok:, field:, year:, questions:, type:, subfield: nil)
    assessment_params = {
      type: type,
      krok_id: krok.id,
      field_id: field.id,
      year_id: year.id,
      subfield_id: subfield&.id,
    }

    if type == "training"
      assessment = assessments_repo.assessments.where(assessment_params).one
    end

    assessment ||= assessments_repo
                   .assessments
                   .command(:create)
                   .call(
                     assessment_params
                       .merge(questions_amount: questions.count),
                   )

    questions.each do |question|
      qrecord = create_question(question, subfield)

      assessment_questions_repo
        .assessment_questions
        .command(:create)
        .call(assessment_id: assessment.id, question_id: qrecord.id)
    end
  end

  def create_question(question, subfield)
    qparams = { title: question["title"].to_s }
    qparams[:subfield_id] = subfield.id if subfield
    qrecord = questions_repo
              .questions
              .command(:create)
              .call(**qparams)

    question["answers"].each do |answer|
      answers_repo
        .answers
        .command(:create)
        .call(
          title: answer["text"].to_s,
          correct: answer["is_checked"],
          question_id: qrecord.id,
        )
    end

    qrecord
  end

  def prep_subfield(name)
    name.gsub(/\,\s\d+$/, "")
  end

  def find_name(current, from)
    current = from[current.downcase] while from[current.downcase]

    current
  end

  def find_or_create_krok(name)
    krok = kroks_repo
           .kroks
           .where(name: name)
           .one
    return krok if krok

    kroks_repo
      .kroks
      .command(:create)
      .call(name: name)
  end

  def find_or_create_field(name, krok)
    field = fields_repo
            .fields
            .where(name: name, krok_id: krok.id)
            .one
    return field if field

    fields_repo
      .fields
      .command(:create)
      .call(name: name, krok_id: krok.id)
  end

  def find_or_create_year(name)
    name = name.map(&:capitalize).join(", ") if name.is_a? Array
    year = years_repo
           .years
           .where(name: name)
           .one
    return year if year

    years_repo
      .years
      .command(:create)
      .call(name: name)
  end

  def find_or_create_subfield(name)
    subfield = subfields_repo
               .subfields
               .where(name: name)
               .one
    return subfield if subfield

    subfields_repo
      .subfields
      .command(:create)
      .call(name: name)
  end
end

class SubfieldsFiller
  include Medlibra::Import[
    "repositories.questions_repo",
  ]

  def call
    questions_repo.questions.where(subfield_id: nil).to_a.each do |question|
      q =
        questions_repo
        .questions
        .where { subfield_id.not(nil) }
        .where(title: question.title)
        .limit(1)
        .one
      next unless q

      questions_repo
        .questions
        .by_pk(question.id)
        .changeset(:update, subfield_id: q.subfield_id)
        .commit
    end
  end
end

class TrainingExamFiller
  include Medlibra::Import[
    "repositories.assessments_repo",
    "repositories.questions_repo",
    "repositories.answers_repo",
    "repositories.assessment_questions_repo",
  ]

  def call
    assessments_repo
      .assessments
      .where(type: "training")
      .combine(questions: :answers)
      .each(&method(:prepare_exam))
  end

  private

  def prepare_exam(assessment)
    exam_questions = []

    assessment.questions.each do |question|
      exam_questions.push(question) if exist_in_exam?(assessment, question)
    end

    persist_questions(assessment, exam_questions) if exam_questions.any?
  end

  def exist_in_exam?(assessment, question)
    relation = assessments_repo.assessments

    relation
      .join(relation.questions)
      .where(type: "exam")
      .where(krok_id: assessment.krok_id)
      .where(field_id: assessment.krok_id)
      .where(year_id: assessment.year_id)
      .where(relation.questions[:title] => question.title)
      .exist?
  end

  def persist_questions(assessment, questions)
    a = create_assessment(assessment, questions.count)
    questions.each do |question|
      create_question(a, question)
    end
  end

  def create_assessment(assessment, questions_amount)
    assessments_repo
      .assessments
      .changeset(
        :create,
        type: "training-exam",
        krok_id: assessment.krok_id,
        field_id: assessment.field_id,
        subfield_id: assessment.subfield_id,
        year_id: assessment.year_id,
        questions_amount: questions_amount,
      ).commit
  end

  def create_question(assessment, question)
    q =
      questions_repo
      .questions
      .changeset(:create, title: question.title, subfield_id: assessment.subfield_id)
      .commit

    question.answers.each do |answer|
      answers_repo
        .answers
        .changeset(:create, title: answer.title, correct: answer.correct, question_id: q.id)
        .commit
    end

    assessment_questions_repo
      .assessment_questions
      .changeset(:create, question_id: q.id, assessment_id: assessment.id)
      .commit
  end
end

Dir["./db/seed_data/testkrok/*"].each do |file_path|
  file = File.read(file_path)
  data = Medlibra::Container["utils.oj"].load(file)

  Filler.new.(data)
end

Dir["./db/seed_data/testukr/*"].each do |file_path|
  file = File.read(file_path)
  data = Medlibra::Container["utils.oj"].load(file)

  Filler.new.(data)
end

SubfieldsFiller.new.call
TrainingExamFiller.new.call
