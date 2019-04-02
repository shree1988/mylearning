import java.text.SimpleDateFormat
properties([
  parameters([
    string (name: 'buildnumber', defaultValue: '100'),
    string (name: 'server', defaultValue: '10.0.0.1')
   ])
])

node{
  stage ('Build'){
    echo "The Build number ${buildnumber}"
  }

  stage ('Deploy'){
    echo "Deployed on server ${server}"
  }
}
