function isQ(line) {
  if(line.startsWith("質問") && line.slice(-1) == "？") {
    return true
  }

  const pattern = /^[0-9|０-９]/
  return pattern.test(line) && line.slice(-1) == "？"
}

function genQ() {
  return new Promise((resolve,reject) => {
    $.ajax({
      url: '/questions',
      type: 'GET',
      dataType: 'json',
      timeout: 300000,
    })
    .done(function(data) {
      console.log(data)
      resolve(data)
    })
    .fail(function(error) {
      console.log(error)
      console.log("ajax failed")
      reject()
    })
  })
}

document.addEventListener("DOMContentLoaded", async()=> {
  let lines
  while(true) {
    const data = await genQ()
    try {
      lines = data.response.split("\n")
      if(lines.length >= 30) {
        break
      }
    } catch (error) {
      $("#questions").html("エラーが発生しました")
      return
    }
  }

  let label_v = ""
  lines.forEach((line,i) => {
    if(isQ(line)) {
      label_v = line
      $("<p>").html(line).appendTo("#questions")
      return
    } else if(i == 0 || line.length == 0) {
      $("<p>").html(line).appendTo("#questions")
      return
    } else if(i+1 == lines.length) {
      $("<p>").html(line).appendTo("#questions")
      return
    }
    $('#questions').append(
      $('<input>').prop({
          type: 'radio',
          id: line,
          name: label_v,
          value: label_v+line+"\n"
      }))
    .append(
      $('<label>').prop({
        for: line
      }).html(line)
    )

    previous = line
  })

  $("#submit").show()
})

async function submit() {
  let answer = ""
  const radios = $("#questions").find("input")
  for (const radio of radios) {
    if(radio.checked) {
      answer += radio.value
    }
  }
  document.getElementById("submit").disabled = "disabled"

  console.log(answer)
  $.ajax({
    url: '/result',
    type: 'GET',
    dataType: 'json',
    data: {answer},
    timeout: 30000,
  })
  .done(function(data) {
    console.log(data)
    document.getElementById("result").innerHTML = data.response
  })
  .fail(function(error) {
    console.log(error)
    console.log("ajax failed")
    document.getElementById("result").innerHTML = "エラーが発生しました"
  })
}