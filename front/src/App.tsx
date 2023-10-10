import React, { Component, ReactElement } from 'react';
import axios from 'axios';

interface iState {
  questions:any
  result: string;
}

class App extends Component<{}, iState> {

  constructor(state:iState) {
    super(state);
    this.state = {
      questions: null,
      result: ""
    }
  }

  submit = () => {
    alert("submit")
  }
  componentDidMount() {
    (async()=> {
      console.log("async");
      //const data = await axios.get('http://localhost:5000/questions', {timeout:300000})
      //console.log(data)

      const myData = [
        {key: 1, name: "Hello"},
        {key: 2, name: "World"},
        {key: 3, name: "etc"}
      ];
      const questions:any[] = []
      myData.forEach((d, i) => {
        console.log(d)
        questions.push(<input type='radio' value={d.name}></input><label>{d.name}</label>)
        /*
        radio.type = "radio"
        radio.id = d.name
        radio.value = d.name

        const label = document.createElement("label")
        label.innerHTML = d.name
        
        document.getElementById("questions")?.appendChild(radio)
        document.getElementById("questions")?.appendChild(label)
        */
      })
      this.setState({questions})
    })()
  }
  render(): React.ReactNode {
    return (
      <div>
        「AI性格診断」<br/>
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
        </div>
        <button id="submit" onClick={this.submit} style={{display:"none"}}>送信</button><br/>
        <br/>
        --分析結果--<br/>
        <br/>
        <div>
        </div>
      </div>
    );
  }
}

export default App;
