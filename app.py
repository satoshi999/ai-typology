# coding: utf-8
from flask import Flask, request, render_template
import json

from boto3.session import Session
from langchain_community.chat_models import BedrockChat
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from langchain.prompts.chat import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
    MessagesPlaceholder,
)

from flask_cors import CORS

config = ""
with open('./config/config.json') as f:
    config = json.load(f)

app = Flask(__name__, template_folder="./front/build", static_folder='./front/build', static_url_path='')
CORS(app)

session = Session(aws_access_key_id=config["aws_access_key"], aws_secret_access_key=config["aws_secret"])

bedrock_runtime = session.client("bedrock-runtime", region_name="us-east-1")

llm = BedrockChat(
    client=bedrock_runtime,
    model_id="anthropic.claude-v2",
    model_kwargs={"max_tokens_to_sample": 500},
)

memory = ConversationBufferMemory(return_messages=True)
prompt = ChatPromptTemplate.from_messages([
    MessagesPlaceholder(variable_name="history"),
    HumanMessagePromptTemplate.from_template("""{input}""")
])

question_n = config["question_n"]

explain_template = """「AI性格診断」というものをやってほしい。\n
\n
AI性格診断の概要\n
\n
進め方の概要:\n
AIが質問を出し、回答の選択肢を設けます。ユーザーが選択肢の番号を選んで回答します。\n
質問は専門用語を避け、わかりやすい言葉で提示されます。\n
回答に基づいて、性格や心理的特徴を分析していきます。\n
ユーザーには{}個質問を提示し、全ての回答を得て現時点での分析結果がユーザーに表示されます。\n
ソシオニクスのタイプやエニアグラムのタイプ、16タイプ、恋愛傾向、心理機能の強弱、自己肯定感、診断結果の信頼度が表示されます。\n
-ソシオニクスのタイプ名を表示します。\n
-エニアグラムのタイプとWingやトライタイプを表示します。\n
-16タイプのアルファベット4文字のタイプを表示します。\n
-恋愛傾向として、恋愛タイプや好きなタイプ、相性のいいタイプなどを表示します。\n
-心理機能の強弱として、ソシオニクスの8つの心理機能(Se,Si,Ne,Ni,Te,Ti,Fe,Fi)の強さを0点~100点で表示します。-自己肯定感、人生の充実度や不安感や自信の点数を表示します。\n
-診断結果の信頼度の点数を表示します。\n
-その人の性格を体現した歌や作品を紹介します。回答者のよく知っているジャンルのものを重点的に紹介します。\n
-他の指標に基づいた性格や恋愛傾向の結果も表示されます。\n
-診断結果から分かることを解説します。\n
\n
分析する指標:\n
ソシオニクスの16タイプやエニアグラムのタイプ、恋愛傾向、心理機能の強弱、自己肯定感、診断結果の信頼度などを取得します。\n
ソシオニクスの場合、どのタイプの特徴に当てはまるかや、サブタイプなどについても分析します。\n
エニアグラムの場合、タイプごとの特徴や心理的な囚われを分析します。Wingやトライタイプも分析します。\n
-16タイプの場合、E/I、S/N、T/F、J/Pの4つの指標を使い、アルファベット4文字のタイプを分析します。\n
恋愛傾向の場合、恋愛タイプや好きなタイプ、相性のいいタイプなどを分析します。\n
-心理機能の強弱の場合、ソシオニクスの8つの心理機能(Se,Si,Ne,Ni,Te,Ti,Fe,Fi)の強さを0点~100点で測定します。-自己肯定感の場合、人生の充実度や不安感や自信について測定します。-診断結果の信頼度は、回答者の回答の矛盾の大きさを調べ、信頼できる結果が出たかを点数化します。-他の性格傾向の指標についても調べていきます。-その人の性格を体現した歌や作品を調べます。回答者のよく知っているジャンルについても調べます。\n
\n
では始めてほしい。{}個まとめて質問を提示し、それぞれ回答の選択肢を設けてください""".format(question_n, question_n)

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

@app.route('/result', methods=['GET'])
def result():              
    answer = request.args.get("answer")
    print(answer)

    result = llm_chain.invoke(answer)
    print("result", result)
    response = result["response"]

    return json.dumps({'response':response})

@app.route('/questions', methods=['GET'])
def questions():
    global llm_chain
    llm_chain = ConversationChain(llm=llm, prompt=prompt, memory=memory)

    result = llm_chain.invoke(explain_template)
    print("questions", result)
    response = result["response"]

    return json.dumps({'response':response})

if __name__ == "__main__":
    app.debug = True
    app.run(host="0.0.0.0")