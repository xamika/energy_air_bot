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
    #Capybara.current_driver = Capybara::Poltergeist::Driver.new(:poltergeist, phantomjs_options: ["--proxy=proxy.corproot.net:8079"])
    Capybara.current_driver = :poltergeist
    duration_times = []
    phone_number = "0796098775"
    @times_won = 0
    @times_lost = 0
    loop do
      begin
        start_time = Time.now
        visit 'https://game.energy.ch'
        start(phone_number)
        answer_question(question) until finished?

        proceed_to_bubbles
        choose_random_bubble
        begin
          if !all('#wingame h1').present? || !find("#wingame h1").text.match(/knapp daneben/)
            puts page.driver.cookies.inspect
            require 'pry'
            binding.pry
            @times_won += 1
            find("#wingame > form > fieldset > div:nth-child(1) > div > input").set(phone_number)
            find("#wingame > form > fieldset > div:nth-child(3) > button").click
            print("√√WIN√√ Check your SMS phone number: " + phone_number)
          else
            puts find("#wingame h1").text
            @times_lost += 1
            print "--Lost--"
          end
        rescue
         puts page.driver.cookies.inspect
         require 'pry'
         binding.pry
        end
        File.open("output.html", "w") do |f|
          f.write(body)
        end
        page.driver.clear_cookies
        finish_time = Time.now
        show_infos(duration_times << (finish_time - start_time).round(1))
      rescue => e
        print "+++++++++++++ERROR+++++++++++++ #{e.message}"
        Capybara.reset_sessions!
      end
    end
  end

  def show_infos(duration_times)
    print Time.now.to_s
    print "Time: " + duration_times.last.to_s
    print "-Average Time: " + (duration_times.inject{ |sum, el| sum + el }.to_f / duration_times.size).round(1).to_s
    print "-Times won: " + @times_won.to_s
    print "-Times lost: " + @times_lost.to_s
    print "\n"
  end

  def answer_question(q)
    if QUESTIONS.key?(q)
      answer_id = QUESTIONS[q]
      #puts "#{q} => #{all(".fields .fieldrow").map(&:text)[answer_id - 1]}"
      find("label[for=\"option#{answer_id}\"]").trigger("click")
      click_next
    else
      find("label[for=\"option1\"]").trigger("click")
      puts "Cannot answer question: #{q}\n
Possible answers:#{all(".fields .fieldrow").map(&:text)}"
      click_next
    end
  end

  def choose_random_bubble
    all("#wingame a").sample.click
  end

  def proceed_to_bubbles
    find("#decision > div > div > div > form > button").click
  rescue
    choose_random_bubble
  end

  def start(phone_number)
    find("body > div.container > div > div > form > div > input").set(phone_number)
    find("body > div.container > div > div > form > button").click
  end

  def finished?
    all("#decision").present?
  end

  def click_next
    find("body > div.container > div > div > form > button").click
  end

  def question
    find("body > div.container > div > div > form > h1").text
  end

  QUESTIONS = {
    "Wie gross ist die Spielfläche des Stade de Suisse?" => 2, #["100m x 70m", "105m x 68m", "90m x 40m"]
    "Wie hiess das Stade de Suisse früher?" => 1, #["Wankdorf", "Stade de YB", "Wenkdorf"]
    "Was bedeutet Air auf Deutsch?" => 2, #["Konzert", "Luft", "Liebe"]
    "Von welchem ehemaligen Energy Air Act ist der Song «Bilder im Kopf»?" => 1, #["Sido", "MoTrip", "Culcha Candela"]
    "Mit welchem Künstler stand Schlangenfrau Nina Burri auf der Bühne?" => 1, #???["RedOne", "DJ Antoine", "OneRepublic"]
    "Wann wurde das Stade de Suisse offiziell fertig gestellt?" => 1, #["2005", "2000", "2001"]
    "In welcher Schweizer Stadt hat Energy KEIN Radiostudio?" => 2, #["Bern", "Basel", "St. Gallen"]
    "Welcher DJ stand noch nie auf der Energy Air Bühne?" => 2, #["Kygo", "Felix Jaehn", "DJ Antoine"]
    "Wie viele Tage dauert das Energy Air?" => 3, #["3", "2", "1"]
    "Wann findet das diesjährige Energy Air statt?" => 2, #["3. September 2017", "2. September 2017", "31. August 2017"]
    "Wo findet das Energy Air statt?" => 3, #["Zürich, Letzigrund", "Basel, St. Jakobshalle", "Bern, Stade de Suisse"]
    "Welche Plätze gibt es am Energy Air?" => 3, #["Nur Stehplätze", "Nur Sitzplätze", "XTRA Circle-Tickets, Steh- und Sitzplätze"]
    "Wann fand das erste Energy Air statt?" => 1, #["Samstag, 6. September 2014", "Freitag, 5. September 2014", "Sonntag, 7. September 2014"]
    "Wie hiess der Energy Air Song im Jahr 2014?" => 3, #["Energy", "Air", "Dynamite"]
    "Wie viele Male standen Dabu Fantastic bereits auf der Energy Air Bühne?" => 1, #["2 Mal", "Kein Mal", "1 Mal"]
    "Zum wievielten Mal findet das Energy Air statt?" => 3, #["Zum 3. Mal", "Zum 4. Mal", "Zum 5. Mal"],
    "Das Energy Air ist ...?" => 1,
    "Ab wann darf man, ohne eine erwachsene Begleitperson, am Energy Air teilnehmen?" => 1,
    "Was ist die obere Altersbeschränkung des Energy Air?" => 2,
    "Wie viel kostet die Energy Air App?" => 2,
    "Welcher dieser Acts Stand schon auf der Stade de Suisse Bühne?" => 1,
    "Welcher Act stand NOCH NIE auf der Energy Air Bühne?" => 3,
    "Wie viele Sitzplätze hat das Stade de Suisse bei Sportveranstaltungen?" => 1,
    "Wer hatte den letzten Auftritt am Energy Air 2016?" => 3,
    "Wie viele Zuschauer passen ins Stade de Suisse?" => 1,
    "In welchem Monat findet das Energy Air jeweils statt?" => 2,
    "Welcher Fussballverein ist im Stade de Suisse Zuhause?" => 1,
    "Was ist das Energy Air als einziger Energy Event?" => 1,
    "Welcher Energy Air Act aus den letzten Jahren stand nur mit seinem Gitarristen auf der Bühne?" => 1, 
    "Welches Stadion ist das grösste der Schweiz?" => 1,
    "Welcher Act stand schon einmal auf der Energy Air Bühne?" => 1,
    "Wie lautet der offizielle Energy Air Hashtag?" => 3, 
    "Welcher Künstler stand NOCH NIE auf der Energy Air Bühne?" => 1,
    "Wie hiess die Energy Air Hymne 2015?" => 1,
    "Von welchem vergangenen Energy Air Act ist der Song «Angelina»?" => 1,
    "Welcher Act performte in einem Karton-Hippie-Bus?" => 3,
    "Wie heissen zwei andere grosse Events von Energy?" => 1,
    "In welchem Jahr stand OneRepublic auf der Bühne des Energy Air?" => 1,
    "Welche deutsche Sängerin stand letztes Jahr auf der Energy Air Bühne?" => 1,
    "Wie viel kostet ein Energy Air Ticket?" => 1,
    "Von wem wird das Energy Air durchgeführt?" => 1,
    "Wie oft pro Jahr findet das Energy Air statt?" => 3,
    "Wie viele Tickets werden für das Energy Air verlost?" => 1,
    "Wo kann man Energy Air Tickets kaufen?" => 3,
    "Welche Farben dominieren das Energy Air Logo?" => 1,
    "Welcher Pop-Sänger stand in diesem Jahr schon auf der Bühne des Stade de Suisse?" => 1,
    "Wann ist die offizielle Türöffnung beim Energy Air?" => 1,
    "Wann fand das Energy Air letztes Jahr statt?" => 1
   #   "Wie heisst Dua Lipas neuster Hit?" => 2,
   #   "In welchem Jahr wurde Kungs geboren?" => 3,
   #   "Wo findet das Energy Air dieses Jahr statt?" => 1,
   #   "Woher stammen Dua Lipas Eltern?" => 3,
   #   "Wie heisst der Frontsänger von OneRepublic?" => 3,
   #   "Wie viel Technikmaterial wurde letztes Jahr für die Show benötigt?" => 3,
   #   "Mit welchem Hit gelang Kungs der europaweite Durchbruch?" => 1,
   #   "In welcher Stadt findet das Energy Air 2016 statt?" => 1,
   #   "In welchem Kanton findet das Gampel Openair statt?" => 3,
   #   "Wie heisst der neue Song von Kungs?" => 2,
   #   "Wo findet das grösste Jazz-Festival Europas statt?" => 2,
   #   "Was gehört für viele bei einem Festival auf den Kopf?" => 3,
   #   "Wo ist Rapper Manillio aufgewachsen?" => 1,
   #   "Aus wie vielen Musikern besteht OneRepublic?" => 2,
   #   "Wie war der Slogan des legendären Woodstock Festival?" => 1,
   #   "Welches Sujet taucht rund ums Energy Air immer wieder auf?" => 3,
   #   "Welches Festival findet in der gleichen Stadt statt wie Energy Air?" => 2,
   #   "Woher stammt das DJ-Duo Filatov & Karas?" => 2,
   #   "Wie lautet Manillios bürgerlicher Name?" => 1,
   #   "Welche Sängerin singt im Remix «Dont Be So Shy» von Filatov & Karas?" => 3,
   #   "Die wievielte Ausgabe des Energy Air findet 2016 statt?" => 2,
   #   "Woher stammt Kungs?" => 1,
   #   "Was ist ein Line-Up?" => 2,
   #   "Wie lautet der offizielle Hashtag für das Energy Air 2016?" => 1,
   #   "Wie heisst der offizielle Energy Air Song 2015?" => 2,
   #   "Welcher Energy Air Act trat schon mal am Tomorrowland auf?" => 1,
   #   "Als was arbeitete Dua Lipa vor ihrer Musikkarriere?" => 2,
   #   "Wie heisst Manillios aktuelles Album?" => 1,
   #   "Wie viele Konzertliebhaber feiern das Energy Air jedes Jahr?" => 3,
   #   "Woher kommt das «Holi Festival of Colours» ursprünglich?" => 2,
   #   "Welche Energy Radiostation existiert nicht?" => 3,
   #   "Wer stand letztes Jahr bei Energy Air als erstes auf der Bühne?" => 3,
   #   "Wie lautet der Slogan des Energy Air?" => 3,
   #   "Welche Acts kommen ans Energy Air?" => 1,
   #   "In welchem Bundesstaat feiern Musikbegeisterte das Coachella Festival?" => 2,
   #   "Welcher dieser Acts war am letzten Energy Air nicht dabei?" => 1
  }
end
