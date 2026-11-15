# MVP WebAR — Ombrelone Solemar

Protótipo de vitrine com visualização 3D e projeção em realidade aumentada usando
[`<model-viewer>`](https://modelviewer.dev) (Google). Serve para validar a experiência
antes de integrar com a Magazord.

![Fluxo](https://img.shields.io/badge/AR-WebXR%20%7C%20Scene%20Viewer%20%7C%20Quick%20Look-0f172a)

## Arquivos

| Arquivo | O que é |
|---|---|
| `index.html` | Página do MVP: viewer 3D, botão de AR e troca de cor do tecido |
| `ombrelone.glb` | Modelo convertido para metallic/roughness (é este que a página carrega) |
| `ombrelone_lateral_octo_tecido_tidelli_agave_casa.glb` | Original do Sketchfab, preservado |
| `ombrelone.usdz` | USDZ do Sketchfab (2,7 MB, USDC). **Plano B** para o AR do iPhone; hoje não é usado |
| `start.sh` | Sobe o servidor local + túnel HTTPS |
| `.nojekyll` | Impede o GitHub Pages de processar o site com Jekyll |
| `README.md` | Este arquivo |

## Rodar

```bash
./start.sh
```

O script:

1. serve a pasta em `http://localhost:8000`;
2. abre um **Cloudflare Quick Tunnel** e imprime uma URL `https://….trycloudflare.com`;
3. encerra o servidor local quando você faz `Ctrl+C`.

Na primeira execução o `npx` baixa o binário do `cloudflared` (leva ~1 min).

<details>
<summary>Equivalente manual (dois terminais)</summary>

```bash
# terminal 1
python3 -m http.server 8000

# terminal 2
npx --yes cloudflared tunnel --url http://localhost:8000
```

</details>

## Testar no celular (Android)

1. Abra a URL pública `https://dufellipeR.github.io/ombrelone-ar/` (ou a do túnel
   local) no **Chrome do Android**.
   HTTPS é obrigatório: em HTTP o navegador bloqueia câmera, sensores e WebXR.
2. Toque em **“Ver no meu espaço”**.
3. Aponte a câmera para o chão, aguarde o retículo e toque para posicionar.
4. Use dois dedos para girar/redimensionar e arraste para mover.

O modelo está em **escala real** (3,78 m × 2,52 m × 3,00 m), então ele aparece no
tamanho verdadeiro do produto.

### Se o botão de AR não aparecer

- A página precisa estar em **HTTPS** (ou `localhost`).
- Chrome atualizado e **Google Play Services para RA** instalado.
- Alguns aparelhos abrem direto no **Google Scene Viewer** em vez do WebXR — é
  esperado, o `ar-modes` já cobre esse caminho.

### iPhone / Safari

Funciona **sem nenhum arquivo extra**. Como não declaramos `ios-src`, o
model-viewer 4.x gera o USDZ **no próprio navegador** no instante em que o botão
de AR é tocado (via `USDZExporter` do three.js). Isso traz dois benefícios:

- a **cor escolhida vai para o AR** — o USDZ é gerado a partir do estado atual da cena;
- não dependemos do MIME type do servidor para `.usdz`, porque o arquivo entregue
  é um `Blob` já tipado como `model/vnd.usdz+zip`. Isso contorna a limitação do
  GitHub Pages, que não mapeia a extensão `.usdz`.

Custo: ~250 ms de conversão e um USDZ de ~7 MB **em memória** (a textura JPEG é
reempacotada como PNG). Nada trafega pela rede nessa etapa.

**Restrição que não pode ser quebrada:** as texturas do `.glb` precisam ser
**JPEG ou PNG**. Converter para WebP ou KTX2 deixa o AR do iPhone **sem textura**,
porque o exportador de USDZ não converte textura comprimida e o Quick Look não lê
WebP. Se um dia otimizar o modelo, use apenas `resize` + `jpeg`.

**Cuidado com iframe:** a entrega ao Quick Look usa um `blob:` URL. Se a página for
embutida num iframe (por exemplo, dentro da Magazord), isso precisa ser revalidado
no iPhone.

**Limitação conhecida:** o exportador emite o aviso
`USDZ does not support double sided materials`. Medimos a geometria: o tecido
principal (`TECIDO`, 3.939 triângulos) é uma superfície fechada, então não deve
sumir ao ser visto por baixo. Peças pequenas (uma faixa de acabamento, a ponta de
um tubo) podem não aparecer em certos ângulos.

**Status do teste:** validado até a geração do USDZ (pacote íntegro, com textura,
7,1 MB). O passo final — o Safari abrir o AR Quick Look — só um iPhone real prova,
e fica a cargo da Solemar.

## Publicar no GitHub Pages

O site vive no repositório **`dufellipeR/ombrelone-ar`** e é servido em
`https://dufellipeR.github.io/ombrelone-ar/`.

### Primeira publicação

O remoto já está configurado (`origin` → `git@github.com:dufellipeR/ombrelone-ar.git`)
e a branch `main` já foi enviada. Se um dia recriar o repositório do zero:

```bash
git remote add origin git@github.com:dufellipeR/ombrelone-ar.git
git push -u origin main
```

Depois, no GitHub: **Settings → Pages → Source: Deploy from a branch →
Branch `main` / pasta `/ (root)` → Save**. O primeiro deploy leva de 1 a 10
minutos; se der 404 no começo, espere e recarregue.

### Atualizar o site

```bash
git add -A
git commit -m "ajuste na cor do tecido"
git push
```

O Pages republica sozinho em ~1 minuto.

### Por que não existe pasta `dist/`

O Pages publica a raiz da branch, então `index.html` e `ombrelone.glb` precisam
estar na raiz do repositório. O `.nojekyll` (vazio) impede o Jekyll de processar
o site desnecessariamente.

### Limites e regras do Pages

- No plano Free o repositório precisa ser **público** (repo privado exige GitHub Pro).
- 100 GB/mês de banda (limite "soft") e 1 GB de site — folgado para esta demo.
- O ToS do GitHub diz que o Pages **não deve ser usado como hospedagem de
  e-commerce**. Esta demo, sem carrinho e sem pagamento, é aceitável para validar;
  quando virar a vitrine AR oficial da Solemar, mova para a hospedagem/domínio do
  cliente. São 3 arquivos: a migração leva minutos.

## Contingência: se o AR do iPhone não abrir

1. O `ombrelone.usdz` (2,7 MB, USDC binário com as texturas JPEG originais) **já
   está no repositório** — veio do
   [Sketchfab](https://sketchfab.com/3d-models/ombrelone-lateral-octo-tecido-tidelli-agave-casa-b6eead8fbb594e9eb9d90b52a5ed4bb7)
   (Download 3D Model → USDZ).
2. Basta declarar `ios-src="ombrelone.usdz"` no `<model-viewer>` e publicar de novo.
3. Atenção: o GitHub Pages **não mapeia** a extensão `.usdz` para `model/vnd.usdz+zip`
   (confirmado no `mime-types-data`), e o Safari pode acabar **baixando** o
   arquivo em vez de abrir o AR. Nesse caso, publique com Cloudflare Pages e um
   arquivo `_headers` na raiz:

```
/*.usdz
  Content-Type: model/vnd.usdz+zip
```

Custo da contingência: o AR do iPhone perde a troca de cor, porque o USDZ é
estático.

## Customizar

### Cores do tecido

Os presets ficam no objeto `CORES`, dentro do `<script>` de `index.html`:

```js
const CORES = {
  natural:   { rotulo: 'Natural',   hex: '#ffffff', ganho: 1.00 },
  agave:     { rotulo: 'Agave',     hex: '#7d8d70', ganho: 1.55 },
  // …
};
```

- `hex` é a cor percebida;
- `ganho` compensa a textura cinza-clara original (valores maiores = cor mais viva);
- para adicionar uma cor, inclua o preset **e** um botão `.sw` correspondente no HTML.

A troca usa a API de materiais do model-viewer, sem recarregar o modelo:

```js
viewer.model.getMaterialByName('TECIDO')
  .pbrMetallicRoughness.setBaseColorFactor([r, g, b, 1]);
```

Os materiais que formam o tecido estão em `MATERIAIS_TECIDO`
(`TECIDO`, `TECIDO01`, `TECIDO02`, `FrontCol`).

### Outro modelo

Basta trocar o `src` do `<model-viewer>`. Se o arquivo vier do Sketchfab, converta
antes — muitos usam `KHR_materials_pbrSpecularGlossiness`, que **não é mais suportado**
pelo three.js (o modelo aparece sem textura):

```bash
npx --yes @gltf-transform/cli metalrough original.glb ombrelone.glb
```

## Diagnóstico

Abra o console do Chrome (`chrome://inspect` no desktop, conectado ao celular) e
procure as linhas `[AR]`:

```
[AR] materiais: ["ESTRUTUR","FrontCol",…]
[AR] canActivateAR: true
[AR] dimensões (m): 3.78 2.52 3.00
[AR] status: session-started
```

`canActivateAR: false` quase sempre significa HTTP em vez de HTTPS, ou navegador
sem suporte.

## Próximos passos

- [ ] Validar o AR Quick Look no iPhone da Solemar (única etapa não verificada aqui)
- [ ] Múltiplos SKUs reais (um `.glb` por variação) e sincronizar com a Magazord
- [ ] Medir conversão (evento no `ar-status: session-started`)
- [ ] Se o arquivo passar de ~5 MB, otimizar **sem** WebP/KTX2 (ver seção iPhone)

## Créditos

Modelo 3D: [Grupo Oca](https://sketchfab.com/3d-models/ombrelone-lateral-octo-tecido-tidelli-agave-casa-b6eead8fbb594e9eb9d90b52a5ed4bb7)
— licença [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/).
Recolorização e projeção em AR: protótipo Solemar.
