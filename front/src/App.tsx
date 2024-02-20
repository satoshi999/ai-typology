import React, { Component, ReactElement } from 'react';
import axios from 'axios';

interface iState {
  questions:Array<{type:string, label:string, name:string, value:string}>
  response: string
  result: string
  msg: string
  btn: string
}

class App extends Component<{}, iState> {

  mounted:boolean = false

  constructor(state:iState) {
    super(state);
    this.state = {
      questions: [],
      response: "",
      result: "",
      msg: "",
      btn: "hide"
    }
  }

  submit = async() => {
    let answer = ""
    const radios:HTMLCollectionOf<HTMLInputElement>|undefined 
      = document.getElementById("questions")?.getElementsByTagName("input")

    if(radios) {
      Array.from(radios).forEach((radio) => {
        if(radio.checked) {
          answer += radio.value
        }
      })
    }
    console.log(answer)
    try {
      this.setState({btn:"disable"})
      const data = await axios.get(`http://${window.location.hostname}:5000/result`, {timeout:300000, params: {answer}})
      this.setState({result: data.data.response})
    } catch (e) {
      this.setState({btn:"show"})
      this.setState({result: "エラーが発生しました"})
    }
  }

  isQuestion(line:string) {
    if(line.startsWith("質問") || line.slice(-1) == "？") {
      return true
    }
  
    const pattern = /^[0-9|０-９]/
    return pattern.test(line) && line.slice(-1) == "？"
  }

  renderBtn = (state: string) => {
    if (state == "show") {
      return <div><button id="submit" onClick={this.submit}>送信</button><br/></div>
    } else if(state == "disable") {
      return <div><button id="submit" onClick={this.submit} disabled>送信</button><br/></div>
    } else {
      return
    }
  }

  renderQuestion = (response:string) => {
    let label_v = ""
    const lines = response.split("\n")

    return lines.map((line:any,i:number) => {
      if(this.isQuestion(line)) {
        label_v = line
        return (<div><p>{line}</p></div>)
      } else if(i == 0 || line.length == 0 || i+1 == lines.length) {
        return (<div><p>{line}</p></div>)
      }

      return (
        <div>
          <input type='radio' value={label_v+line+"\n"} name={label_v}></input>
          <label>{line}</label>
        </div>
      )
    })
  }

  componentDidMount() {
    if(this.mounted) return;
    this.mounted = true;

    (async()=> {
      let lines = []
      let response = ""
      while(true) {
        const data = await axios.get(`http://${window.location.hostname}:5000/questions`, {timeout:300000})
        console.log(data)
          try {
          lines = data.data.response.split("\n")
          if(lines.length >= 30) {
            response = data.data.response
            break
          }
        } catch (error) {
          this.setState({msg:"エラーが発生しました"})
          return
        }
      }
      this.setState({response: response})
      this.setState({btn:"show"})
    })()
  }
  render(): React.ReactNode {
    return (
      <div>
        「AI性格診断」(ver1.03)<br/>
        <br/>
        1.進め方の概要:<br/>
        - AIが質問を出し、回答の選択肢を設けます。ユーザーが選択肢の番号を選んで回答します。<br/>
        - 質問は専門用語を避け、わかりやすい言葉で提示されます。<br/>
        <br/>
        2.分析する指標:<br/>
        - ソシオニクスの16タイプやエニアグラムのタイプ、恋愛傾向、心理機能の強弱、自己肯定感、診断結果の信頼度などを取得します。<br/>
        - ソシオニクスの場合、どのタイプの特徴に当てはまるかや、サブタイプなどについても分析します。<br/>
        - エニアグラムの場合、タイプごとの特徴や心理的な囚われを分析します。Wingやトライタイプも分析します。<br/>
        - 16タイプの場合、E/I、S/N、T/F、J/Pの4つの指標を使い、アルファベット4文字のタイプを分析します。<br/>
        - 恋愛傾向の場合、恋愛タイプや好きなタイプ、相性のいいタイプなどを分析します。<br/>
        - 心理機能の強弱の場合、ソシオニクスの8つの心理機能(Se,Si,Ne,Ni,Te,Ti,Fe,Fi)の強さを0点~100点で測定します。<br/>
        - 自己肯定感の場合、人生の充実度や不安感や自信について測定します。<br/>
        - 診断結果の信頼度は、回答者の回答の矛盾の大きさを調べ、信頼できる結果が出たかを点数化します。<br/>
        - 他の性格傾向の指標についても調べていきます。<br/>
        - その人の性格を体現した歌や作品を調べます。回答者のよく知っているジャンルについても調べます。<br/>
        <br/>
        <br/>
        では診断します。AI君よろしくお願いします<br/>
        <br/>
        <br/>
        ---------
        <br/>
        <div id="questions">
          {this.renderQuestion(this.state.response)}
        </div>
        {this.renderBtn(this.state.btn)}
        <br/>
        <br/>
        --分析結果--<br/>
        <br/>
        <div>
          {
            this.state.result.split("\n").map((line) => {
              return (<p>{line}</p>)
            })
          }
        </div>
      </div>
    );
  }
}

export default App;
