class Question < ApplicationRecord
    validates :text, presence: true

    has_many :answer_choices, 
        class_name: 'AnswerChoice',
        foreign_key: :question_id,
        primary_key: :id

    belongs_to :poll,
        class_name: 'Poll',
        foreign_key: :poll_id,
        primary_key: :id

    has_many :responses, 
        through: :answer_choices, 
        source: :responses

    def slow_results
        possible_answers = self.answer_choices.includes(:responses)

        count_hash = Hash.new(0)
        possible_answers.each do |answer_obj|
            count_hash[answer_obj.text] = answer_obj.responses.length
        end

        count_hash
            
    end

    def results
        acs = AnswerChoice.find_by_sql([<<-SQL,id])
            SELECT
                answer_choices.text,COUNT(responses.id) AS num_responses
            FROM
                answer_choices
            LEFT OUTER JOIN
                responses ON responses.answer_choice_id = answer_choices.id
            WHERE
                answer_choices.question_id = ?
            GROUP BY
                answer_choices.id
        SQL

        acs.inject({}) do |results, ac|
            results[ac.text] = ac.num_responses
            results
        end
    end
end