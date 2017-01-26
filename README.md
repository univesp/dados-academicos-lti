# Dados Acadêmicos LTI

Esta aplicação permite que os alunos consultem seus dados acadêmicos, como matriz curricular, histórico e indicadores, de dentro do AVA, a partir de integração via LTI (Learning Tools Interoperability®).

Os dados acadêmicos são fornecidos via consulta à API do SGA (Sistema de Gestão Acadêmica) da UNIVESP, em que essa gera três arquivos: activities.json, que alimenta a matriz curricular; grades.json, que alimenta o histórico; e rates.json, que alimenta os indicadores. Esses arquivos são baixados sazonalmente do SGA e enviados para o diretório data/ para servirem como fonte dos dados consultados.


### Autor

Evandro Almeida (evandrodevops@gmail.com)


### Tecnologias empregadas

* RVM (Gerenciamento de versões do Ruby)
* Ruby 2.3.0 (versão definida no arquivo source/.ruby-version)
* Sinatra (Framework web)
* Passenger (Servidor web)
* IMS-LTI (Gema para integração com o AVA)
* Pony (Gema para envio de e-mail)


### Instruções de instalação

1. Clone o projeto do GitLab para o diretório no servidor

```
$ git clone https://github.com/univesp/dados-academicos-lti.git
```

2. Crie os diretórios data/ e log/, não versionados, no diretório raiz da aplicação

3. Solicite o diretório config/, que não foi versionado, ao administrador e o copie para dentro do diretório raiz da aplicação.

4. Instale a gem "bundler", caso ainda não o tenha feito, e execute o comando "bundle" dentro do diretório raiz
```
$ gem install bundler
$ bundle
```
5. No ambiente de produção, configure uma location no NGINX para essa aplicação.

```
location ~ ^/dados-academicos-lti(/.*|$) {
    alias <RAIZ>/dados-academicos-lti/public$1;
    passenger_base_uri /dados-academicos-lti;
    passenger_app_root <RAIZ>/dados-academicos-lti;
    passenger_document_root <RAIZ>/dados-academicos-lti/public;
    passenger_enabled on;
    passenger_friendly_error_pages on;
}
```
