require "roda"

class Router < Roda
  include Helpers

  plugin :sessions, secret: Settings.secret_key
  plugin :assets, css: "app.css", js: "app.js", path: Settings.root.join("public"), css_dir: "", js_dir: "", timestamp_paths: true
  plugin :render, views: Settings.root.join("app/views")
  plugin :partials
  plugin :route_csrf, require_request_specific_tokens: false, check_header: true
  plugin :flash
  plugin :link_to
  plugin :path
  plugin :all_verbs
  plugin :status_303 # for Turbo
  plugin :turbo
  plugin :forme_set, secret: Settings.secret_key
  plugin :content_for
  plugin :typecast_params

  path(:root, "/")
  path(:categories, "/categories")
  path(Category) { |category| "/categories/#{category.id}" }
  path(:expenses, "/expenses")
  path(:ignore_expense) { |expense| "/expenses/#{expense.id}/ignore" }
  path(Expense) { |expense| "/expenses/#{expense.id}" }
  path(:rules, "/rules")
  path(:apply_rule) { |rule| "/rules/#{rule.id}/apply" }
  path(Rule) { |rule| "/rules/#{rule.id}" }

  route do |r|
    r.assets

    check_csrf!

    r.root do
      @spending = Category.monthly_breakdown
      @categories = Category.order(:name).all

      view "home"
    end

    r.on "categories" do
      r.get true do
        @categories = Category.order(:name).all
        @new_category = Category.new

        view "categories/index"
      end

      r.post true do
        category = forme_set(Category.new).save

        r.redirect categories_path
      end

      r.on Integer do |id|
        category = Category.with_pk!(id)

        r.delete true do
          category.destroy

          r.redirect categories_path
        end
      end
    end

    r.on "expenses" do
      r.get true do
        @pagy, @expenses = pagy Expense.reverse(:date, :id).eager(:category)
        @new_expense = Expense.new(date: Expense.last_updated&.date)
        @categories = Category.order(:name).all

        view "expenses/index"
      end

      r.post true do
        expense = forme_set(Expense.new).save

        Rule.order(:id).each do |rule|
          rule.apply(expense) if rule.matches_expense?(expense)
        end

        flash["notice"] = "Expense \"#{expense.description}\" created with category \"#{expense.category&.name}\""

        r.redirect expenses_path
      end

      r.on Integer do |id|
        expense = Expense.with_pk!(id)

        r.put true do
          forme_set(expense).save
          categories = Category.order(:name).all

          turbo_stream.replace dom_id(expense), partial("expenses/expense", locals: { expense: expense, categories: categories })
        end

        r.delete true do
          expense.destroy

          turbo_stream.remove dom_id(expense)
        end
      end
    end

    r.on "rules" do
      r.get true do
        @rules = Rule.order(:id).all
        @new_rule = Rule.new
        @categories = Category.order(:name).all

        view "rules/index"
      end

      r.post true do
        rule = forme_set(Rule.new).save
        rule.apply_all

        flash["notice"] = "Rule created and applied"

        r.redirect rules_path
      end

      r.on Integer do |rule_id|
        rule = Rule.with_pk!(rule_id)

        r.post "apply" do
          rule.apply_all

          flash["notice"] = "Rule applied"

          r.redirect rules_path
        end

        r.delete true do
          rule.destroy

          r.redirect rules_path
        end
      end
    end
  end

  private

  def pagy(dataset)
    tp = typecast_params
    dataset = dataset.paginate(tp.pos_int("page") || 1, 100)
    pagy = Pagy.new(count: dataset.pagination_record_count, page: dataset.current_page, items: dataset.page_size)

    [pagy, dataset.all]
  end
end
