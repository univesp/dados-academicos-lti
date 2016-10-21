# AVA Academic Record

Esta aplicação permite que os alunos consultem seus dados acadêmicos, como matriz curricular, histórico e indicadores, de dentro do AVA, a partir de integração via LTI (Learning Tools Interoperability®).

Os dados acadêmicos são fornecidos via consulta à API do SGA (Sistema de Gestão Acadêmica) da UNIVESP, em que essa gera três arquivos, a saber activities.json, que alimenta a matriz curricular; grades.json, que alimenta o histórico; e rates.json, que alimenta os indicadores. Esses arquivos são baixados diariamente do SGA e enviados para o diretório data/, no diretório source/ dessa aplicação, para servirem como fonte dos dados consultados.


### Autor

Evandro Almeida (evandro.almeida@univesp.br)


### Tecnologias empregadas

* RVM (Gerenciamento de versões do Ruby)
* Ruby 2.2.1 (versão definida no arquivo source/.ruby-version)
* Sinatra (Framework web)
* Passenger (Servidor web)
* IMS-LTI (Gema para integração com o AVA)
* Pony (Gema para envio de e-mail)


### Instruções de instalação

1. Clone o projeto do GitLab para o diretório no servidor

```
$ git clone https://gitlab.com/evandro-almeida/ava-academic-record.git
```

2. Crie os diretórios data/ e log/, não versionados, no diretório source/ da aplicação

3. Solicite o diretório config/, que não foi versionado, ao administrador e o copie para dentro do diretório source/ da aplicação.

4. Instale a gem "bundler", caso ainda não o tenha feito, e execute o comando "bundle" dentro do diretório source/
```
$ gem install bundler
$ bundle
```
5. Configure uma location nos sites do NGINX para essa aplicação.

```
location ~ ^/ava-academic-record(/.*|$) {
	alias <app_root_path>/ava-academic-record/source/public$1;
	passenger_base_uri /ava-academic-record;
	passenger_app_root <app_root_path>/ava-academic-record/source;
    passenger_document_root <app_root_path>/ava-academic-record/source/public;
    passenger_enabled on;
    passenger_friendly_error_pages on;
}
```
