require "test_helper"

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  def setup
    Capybara.default_driver = :poltergeist
  end

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
  end
end


class AirGeneratorTest < ActionDispatch::IntegrationTest
  test "generate energy air tickets" do
    Capybara.current_driver = :poltergeist
    duration_times = []
    phone_number = "0798695031"
    @times_won = 0
    loop do
      start_time = Time.now
      visit 'https://game.energy.ch'
      start
      answer_question(question) until finished?

      proceed_to_bubbles
      choose_random_bubble
      unless all("#wingame h1").present?
        #puts page.driver.cookies.inspect
        @times_won += 1
        find("#wingame > form > fieldset > div:nth-child(1) > div > input").set(phone_number)
        find("#wingame > form > fieldset > div:nth-child(3) > button").click
        print("√√WIN√√ Check your SMS phone number: " + phone_number)
      else
        print "--Lost--"
      end
      File.open("output.html", "w") do |f|
        f.write(body)
      end
      page.driver.clear_cookies
      finish_time = Time.now
      show_infos(duration_times << (finish_time - start_time).round(1))
    end
  end

  def show_infos(duration_times)
    print "Time: " + duration_times.last.to_s
    print "-Average Time: " + (duration_times.inject{ |sum, el| sum + el }.to_f / duration_times.size).round(1).to_s
    print "-Times won: " + @times_won.to_s
    print "\n"
  end

  def answer_question(q)
    if QUESTIONS.key?(q)
      answer_id = QUESTIONS[q]
      find("label[for=\"option#{answer_id}\"]").trigger("click")
      click_next
    else
      raise "Cannot answer question: #{q}\n
Possible answers:#{all(".fields .fieldrow").map(&:text)}"
    end
  end

  def choose_random_bubble
    all("#wingame a").sample.click
  end

  def proceed_to_bubbles
    find("#decision > div > div > form > button").click
  end

  def start
    find("body > div.container > div > div > div.round-button > div").click
  end

  def finished?
    all("#decision").present?
  end

  def click_next
    click_button "Weiter"
  end

  def question
    find("body > div.container > div > div > form > h1").text
  end

  QUESTIONS = {
      "Wie heisst Dua Lipas neuster Hit?" => 2,
      "In welchem Jahr wurde Kungs geboren?" => 3,
      "Wo findet das Energy Air dieses Jahr statt?" => 1,
      "Woher stammen Dua Lipas Eltern?" => 3,
      "Wie heisst der Frontsänger von OneRepublic?" => 3,
      "Wie viel Technikmaterial wurde letztes Jahr für die Show benötigt?" => 3,
      "Mit welchem Hit gelang Kungs der europaweite Durchbruch?" => 1,
      "In welcher Stadt findet das Energy Air 2016 statt?" => 1,
      "In welchem Kanton findet das Gampel Openair statt?" => 3,
      "Wie heisst der neue Song von Kungs?" => 2,
      "Wo findet das grösste Jazz-Festival Europas statt?" => 2,
      "Was gehört für viele bei einem Festival auf den Kopf?" => 3,
      "Wo ist Rapper Manillio aufgewachsen?" => 1,
      "Aus wie vielen Musikern besteht OneRepublic?" => 2,
      "Wie war der Slogan des legendären Woodstock Festival?" => 1,
      "Welches Sujet taucht rund ums Energy Air immer wieder auf?" => 3,
      "Welches Festival findet in der gleichen Stadt statt wie Energy Air?" => 2,
      "Woher stammt das DJ-Duo Filatov & Karas?" => 2,
      "Wie lautet Manillios bürgerlicher Name?" => 1,
      "Welche Sängerin singt im Remix «Dont Be So Shy» von Filatov & Karas?" => 3,
      "Die wievielte Ausgabe des Energy Air findet 2016 statt?" => 2,
      "Woher stammt Kungs?" => 1,
      "Was ist ein Line-Up?" => 2,
      "Wie lautet der offizielle Hashtag für das Energy Air 2016?" => 1,
      "Wie heisst der offizielle Energy Air Song 2015?" => 2,
      "Welcher Energy Air Act trat schon mal am Tomorrowland auf?" => 1,
      "Als was arbeitete Dua Lipa vor ihrer Musikkarriere?" => 2,
      "Wie heisst Manillios aktuelles Album?" => 1,
      "Wie viele Konzertliebhaber feiern das Energy Air jedes Jahr?" => 3,
      "Woher kommt das «Holi Festival of Colours» ursprünglich?" => 2,
      "Welche Energy Radiostation existiert nicht?" => 3,
      "Wer stand letztes Jahr bei Energy Air als erstes auf der Bühne?" => 3,
      "Wie lautet der Slogan des Energy Air?" => 3,
      "Welche Acts kommen ans Energy Air?" => 1,
      "In welchem Bundesstaat feiern Musikbegeisterte das Coachella Festival?" => 2,
      "Welcher dieser Acts war am letzten Energy Air nicht dabei?" => 1
  }
end