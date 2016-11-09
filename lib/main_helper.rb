before do
  config = File.open( File.join(File.dirname(__FILE__), '../config/canvas.yml') ) { |yml| YAML::load(yml) }
  OAUTH_KEY = config['oauth_key'].to_s	
end

helpers do

  # Authorizes the use of application by comparing the key sent via Canvas LTI call with a predefined key.
  #        
  # @param [String] oauth_key Key to be compared
  # @return [Boolean] Result of comparison
  def authorize key
    return key.eql? OAUTH_KEY
  end


  # Mounts the DOM of the activities tab.
  #        
  # @param [String] academic_register Student's academic register	
  # @return [String] DOM of activities tab
  def mount_activities_dom academic_register
    activities_dom = ''
    last_bimester = 0

    activities_file = JSON.parse( File.read( File.join(File.dirname(__FILE__), '../data/activities.json' ), :encoding => 'utf-8') )

    # Some users don't have an academic register. Ex.: AVA Admin
    return 'RA inválido' if not activities_file.key? academic_register

    activities_dom <<  "<table class='table'>"\
      "<thead><tr>"\
      "<th>Bimestre</th>"\
      "<th>Código</th>"\
      "<th>Disciplina</th>"\
      "</tr></thead><tbody>" 

    academic_records = activities_file[academic_register]
    academic_records.reverse.each do |record| # now a student 
    # can have many academic records associated

      # Because of the structure of file (Course => Bimesters => Activities) it's necessary to convert the values back to hash 
      # Thus "activities_data.values" equates to "Bimesters => Activities", discarding the courses
      bimesters = Hash[*record.values]
      bimesters.each_with_index do |bim, bim_index|
        index = last_bimester + bim[0].to_i
        activities = bim[1] || []
 
        activities_dom << '<tr>'
        activities_dom << "<td rowspan='#{activities.size}'>#{index}</td>"
      
        activities.sort! { |x,y| x['name'] <=> y['name'] }  
        activities.each_with_index do |a, i|                                     
          activities_dom << '<tr>' if i > 0
          activities_dom << "<td>#{a['code']}</td><td>#{a['name']}</td>"
          activities_dom << '</tr>'
        end
        last_bimester = index if bim_index == bimesters.size - 1
      end 
    end
    activities_dom << '</tbody></table>'
    activities_dom
  end


  # Mounts the DOM of the grades tab.
  #        
  # @param [String] academic_register Student's academic register	
  # @return [String] DOM of grades tab
  def mount_grades_dom academic_register
    grades_dom = ''
    grades_file = JSON.parse( File.read( File.join(File.dirname(__FILE__), '../data/grades.json'), :encoding => 'utf-8') )

    # Some users don't have an academic register. Ex.: AVA Admin
    return 'RA inválido' if not grades_file.key? academic_register

    grades_dom << "<table class='table'><thead>"\
      "<tr><th style='width:10%'>Código</th>"\
      "<th style='width:20%'>Disciplina</th>"\
      "<th style='width:15%'>Data de Conclusão</th>"\
      "<th style='width:15%'>Nota Final</th>"\
      "<th style='width:20%'>Frequência Total (%)</th>"\
      "<th style='width:20%'>Situação Atual</th>"\
      "</tr></thead><tbody>"

    all_activities = []
    academic_records = grades_file[academic_register]
    academic_records.each do |record| # now a student 
    # can have many academic records associated
      record.each do |activity|
        all_activities << activity
      end
    end
         
    all_activities.sort! { |x,y| x['name'] <=> y['name'] }
    all_activities.each do |activity|
      grade = activity['grade'].to_s.gsub('.',',')
      attendance = activity['attendance'].to_s.gsub('.',',')
      status = activity['status']
      if activity['hide_grades_and_attendances'] or activity['status'] == 'Aproveitamento de Estudos'
        grade = '-'
        attendance = '-'
        status = 'Concluído' if activity['hide_grades_and_attendances'] and activity['status'] == 'Aprovado' 
      end
      grades_dom << "<tr><td style='width:10%'>#{activity['code']}</td>"\
        "<td style='width:20%'>#{activity['name']}</td>"\
        "<td style='width:15%'>#{activity['date_conclusion']}</td>"\
        "<td style='width:15%'>#{grade}</td>"\
        "<td style='width:20%'>#{attendance}</td>"\
        "<td style='width:20%'>#{status}</td></tr>"
    end       
    
    grades_dom << '</tbody></table>'
    grades_dom
  end

	
  # Mounts the final DOM of the page that will be displayed to the user.
  #        
  # @param [String] activities_dom DOM of activities tab
  # @param [String] grades_dom DOM of grades tab
  # @param [String] rates_dom DOM of rates tab
  # @return [String] DOM of the page
  def mount_page_dom activities_dom, grades_dom, rates_dom

    rates_file = File.join(File.dirname(__FILE__), '../data/rates.json')		
    last_update_time = File.mtime rates_file # last update time is defined by the modification date of rates.json file

    "<!DOCTYPE html>
    <html>
    <head>
      <title>Dados Acadêmicos</title>
      <link rel='stylesheet' href='https://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.min.css'>
      <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'>
      <script src='https://code.jquery.com/jquery-1.11.3.min.js'></script>
      <script src='https://code.jquery.com/ui/1.11.4/jquery-ui.min.js'></script>
      <style>
        #tabs {
          border: none;
        }
      </style>
    </head>
    <body>
    <div class='container'>
      <div>
        <h3>Dados Acadêmicos</h3>
      </div>

      <div id='tabs'>	
        <ul>
          <li><a href='#activities'>Matriz curricular</a></li>
          <li><a href='#grade'>Histórico</a></li>
          <li><a href='#rates'>Indicadores</a></li>
        </ul>
        <div id='activities'>
          #{activities_dom}
        </div>
        <div id='grade'>
          #{grades_dom}
        </div>
        <div id='rates'>
          #{rates_dom}
        </div>
      </div>

      <div class='alert alert-warning' role='alert'>
        <div><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>&nbsp;&nbsp;Informações para simples conferência. Para retirar seu Histórico Escolar, solicite-o ao CASAluno.</div>
        <div><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>&nbsp;&nbsp;As notas são atualizadas somente após o término dos processos de avaliação e revisão.</div>
        <div><span class='glyphicon glyphicon-exclamation-sign' aria-hidden='true'></span>&nbsp;&nbsp;Última sincronização realizada em #{last_update_time.strftime '%d/%m/%Y'}</div>
      </div>			

      <script>
        jQuery(function() {
	        jQuery( '#tabs' ).tabs();
        });
      </script>

      <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', 'UA-65982204-3', 'auto');
        ga('send', 'pageview', {
          'hitCallback': function() {
            console.log('--> Page hit successfully sent to Analytics <--');
          }
        });
      </script>

    </body>
    </html>"	
  end


  # Mounts the DOM of the rates tab.
  #        
  # @param [String] academic_register Student's academic register	
  # @return [String] DOM of rates tab
  def mount_rates_dom academic_register

    rates_file = JSON.parse( File.read( File.join(File.dirname(__FILE__), '../data/rates.json'), :encoding => 'utf-8') )

    # Some users don't have an academic register. Ex.: AVA Admin
    return 'RA inválido' if not rates_file.key? academic_register

    rates_data = rates_file[academic_register] 

    rates_dom = ''
    rates_dom << "<p>Percentual de progressão: <strong>#{rates_data['progression_rate'].to_s.gsub('.',',')}%</strong></p>"
    rates_dom << "<p>Rendimento: <strong>#{rates_data['achievement_rate'].to_s.gsub('.',',')}</strong></p>"
  end

end
