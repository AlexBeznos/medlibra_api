# frozen_string_literal: true

require "oj"
require "ruby-progressbar"
require_relative "../system/boot"
require_relative "../system/medlibra/import"

module Fillers
  module Concurrent
    def concurrently(elements, &block)
      elements.each_slice(8) do |slice|
        threads =
          slice.map do |element|
            Thread.new do
              block.call(element)
            end
          end

        threads.each(&:value)
      end
    end
  end

  class Creator
    KROKS_MAPPER = {
      "крок m" => "Крок М",
    }.freeze

    FIELDS_MAPPER = {
      "загальна лікарська підготовка" => "Лікувальна справа",
      "акушерство" => "Акушерська справа",
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
    include Concurrent

    def call(data)
      return if data["subField"].first.to_s.match(/USMLE/)
      return if data["questions"].empty?

      krok = find_or_create_krok(
        find_name(
          data["krokType"],
          KROKS_MAPPER,
        ),
      )
      field = find_or_create_field(find_name(data["field"], FIELDS_MAPPER), krok)
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
      return if questions.empty?

      assessment_params = {
        type: type,
        krok_id: krok.id,
        field_id: field.id,
        year_id: year.id,
        subfield_id: subfield&.id,
      }

      assessment = assessments_repo.assessments.where(assessment_params).one if type == "training"

      assessment ||= assessments_repo
                     .assessments
                     .command(:create)
                     .call(
                       assessment_params
                         .merge(questions_amount: questions.count),
                     )

      concurrently(questions) do |question|
        if question["answers"].any?
          qrecord = create_question(question, subfield)

          assessment_questions_repo
            .assessment_questions
            .command(:create)
            .call(assessment_id: assessment.id, question_id: qrecord.id)
        end
      end
    end

    def create_question(question, subfield)
      qparams = { title: question["title"].to_s }
      qparams[:subfield_id] = subfield.id if subfield
      qrecord = questions_repo
                .questions
                .command(:create)
                .call(**qparams)

      concurrently(question["answers"]) do |answer|
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

  class Subfielder
    include Concurrent
    include Medlibra::Import[
      "repositories.questions_repo",
      "repositories.assessments_repo",
    ]

    def call(progressbar)
      questions = questions_repo.questions.where(subfield_id: nil).to_a
      progressbar.total = questions.count

      concurrently(questions) do |question|
        progressbar.increment

        q = find_by_assessment(question)
        update_question(question, q) if q
        q = find_by_title(question)
        update_question(question, q) if q
      end
    end

    private

    def find_assessment(question)
      assessments_repo
        .assessments
        .join(question_relation)
        .where(question_relation[:id] => question.id)
        .limit(1)
        .one
    end

    def find_by_assessment(question)
      assessment = find_assessment(question)

      assessments_repo
        .assessments
        .join(question_relation)
        .where(question_relation[:title] => question.title)
        .where(type: "training")
        .where(krok_id: assessment.krok_id)
        .where(field_id: assessment.field_id)
        .where(year_id: assessment.year_id)
        .limit(1)
        .one
    end

    def find_by_title(question)
      question_relation
        .where { subfield_id.not(nil) }
        .where(title: question.title)
        .limit(1)
        .one
    end

    def update_question(qcurrent, qnext)
      question_relation
        .by_pk(qcurrent.id)
        .changeset(:update, subfield_id: qnext.subfield_id)
        .commit
    end

    def question_relation
      questions_repo
        .questions
    end
  end

  class TrainingExamCreator
    include Concurrent
    include Medlibra::Import[
      "repositories.assessments_repo",
      "repositories.questions_repo",
      "repositories.answers_repo",
      "repositories.assessment_questions_repo",
    ]

    def call(progressbar)
      assessments =
        assessments_repo
        .assessments
        .where(type: "training")
        .to_a

      progressbar.total = assessments.count

      assessments.each do |assessment|
        progressbar.increment
        prepare_exam(assessment)
      end
    end

    private

    def prepare_exam(assessment)
      questions_relation = questions_by_assessment(assessment)
      return unless questions_relation.exist?

      questions = questions_relation.to_a

      persist_questions(assessment, questions) if questions.count.positive?
    end

    def questions_by_assessment(assessment)
      arelation = assessments_repo.assessments
      qrelation = questions_repo.questions

      qrelation
        .join(arelation)
        .where(arelation[:type] => "exam")
        .where(arelation[:krok_id] => assessment.krok_id)
        .where(arelation[:field_id] => assessment.field_id)
        .where(arelation[:year_id] => assessment.year_id)
        .where(qrelation[:subfield_id] => assessment.subfield_id)
        .distinct
        .combine(:answers)
    end

    def persist_questions(assessment, questions)
      a = create_assessment(assessment, questions.count)
      concurrently(questions) do |q|
        create_question(a, q)
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

      concurrently(question.answers) do |answer|
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
end

puts "Start seeding..."
testkrok_paths = Dir["./db/seed_data/testkrok/*"]
progressbar = ProgressBar.create(title: "Testkrok upload", total: testkrok_paths.count)
testkrok_paths.each do |file_path|
  file = File.read(file_path)
  data = Medlibra::Container["utils.oj"].load(file)

  Fillers::Creator.new.(data)
  progressbar.increment
end

testukr_paths = Dir["./db/seed_data/testukr/*"]
progressbar = ProgressBar.create(title: "Testukr upload", total: testukr_paths.count)
testukr_paths.each do |file_path|
  file = File.read(file_path)
  data = Medlibra::Container["utils.oj"].load(file)

  Fillers::Creator.new.(data)
  progressbar.increment
end

progressbar = ProgressBar.create(title: "Subfields filling")
Fillers::Subfielder.new.call(progressbar)

progressbar = ProgressBar.create(title: "Training exam creation")
Fillers::TrainingExamCreator.new.call(progressbar)
