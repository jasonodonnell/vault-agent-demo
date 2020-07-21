package main

import "html/template"

var tmpl = template.Must(template.New("root").Parse(`
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>Hashicorp Test Application</title>
    <meta name="description" content="Hashicorp Test Application">
    <meta name="author" content="Hashicorp">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
    <script src="https://unpkg.com/feather-icons"></script>
</head>

<body>
  <div class="jumbotron" style="padding: 1em;background-color: black;border-radius: 0;">
    <div class="text-left">
      <img src="https://www.datocms-assets.com/2885/1588890753-hashicorpprimarylogorgb.svg" width=165 height=45 alt="HashiCorp Logo">
    </div>
  </div>  
<div class="container">
    <h2>PostgreSQL Connection Status</h2>
    <table class="table table-striped">
      <thead class="thead-light">
        <tr>
          <th>Connected</th>
          <th>Username</th>
          <th>PostgreSQL Version</th>
        </tr>
      </thead>
      <tbody>
			<tr><td><i data-feather="check-circle" style="color: green;"></i></td><td>{{.Username}}</td><td>{{.Version}}</td></tr>
      </tbody>
    </table>

    <h2>Coffees</h2>
    <table class="table table-striped">
      <thead class="thead-light">
        <tr>
          <th>Name</th>
          <th>Species</th>
          <th>Regions</th>
          <th>Comment</th>
        </tr>
      </thead>
      <tbody>
        {{range .Coffee}}
            <tr><td>{{.Name}}</td><td>{{.Species}}</td><td>{{.Regions}}</td><td>{{.Comment}}</td></tr>
        {{end}}
      </tbody>
      <script>
        feather.replace()
      </script>
    </table>
  </div>
</body>
</html>
`))
