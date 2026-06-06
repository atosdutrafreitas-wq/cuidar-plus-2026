# Cuidar+ — Plataforma de Acompanhamento de Medicação para Idosos

## Sobre o Projeto

O **Cuidar+** é uma plataforma completa de monitoramento medicamentoso para idosos, com foco em:
- Adesão medicamentosa
- Segurança
- Acessibilidade (letras grandes, botões gigantes, alto contraste)
- Suporte familiar
- Alertas inteligentes
- Emergência rápida (botão AJUDA)

---

## Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| Mobile/Web | Flutter |
| Backend | Firebase |
| Banco de Dados | Cloud Firestore |
| Autenticação | Firebase Auth (OTP por SMS) |
| Notificações | Firebase Cloud Messaging + Local Notifications |
| Armazenamento | Firebase Storage |
| OCR | Google ML Kit |
| QR Code | qr_flutter |
| Estado | Riverpod |
| Navegação | go_router |

---

## Estrutura do Projeto

```
lib/
├── core/          # Tema, constantes, configurações
├── models/        # Modelos de dados (Firestore)
├── services/      # Firebase, notificações, OCR
├── repositories/  # Camada de acesso a dados
├── providers/     # Estado (Riverpod)
├── screens/       # Telas do app
│   ├── auth/      # Login, OTP, registro
│   ├── home/      # Home do idoso e familiar
│   ├── medications/ # Lista e cadastro de medicações
│   ├── alerts/    # Alertas pendentes
│   ├── qr_code/   # QR Code médico
│   ├── profile/   # Perfil do usuário
│   ├── family/    # Painel familiar
│   ├── reports/   # Relatórios de adesão
│   └── ocr/       # Escaneamento de receita
├── widgets/       # Componentes reutilizáveis
├── routes/        # Configuração de rotas
└── main.dart      # Entry point
```

---

## Pré-requisitos

1. **Flutter SDK** — [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **Conta Firebase** — [https://console.firebase.google.com](https://console.firebase.google.com)
3. **FlutterFire CLI** — para configurar o Firebase

---

## Configuração do Firebase

### 1. Criar projeto Firebase

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Clique em **"Adicionar projeto"**
3. Nome: `cuidar-plus` (ou de sua escolha)
4. Ative o Google Analytics (opcional)

### 2. Habilitar serviços

No Firebase Console, ative:
- **Authentication** → Método: Telefone (SMS OTP)
- **Firestore Database** → Modo de produção
- **Storage** → Regras padrão
- **Cloud Messaging** → Automático

### 3. Configurar o app Flutter

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Na pasta do projeto
cd C:\cuidar_plus
flutterfire configure --project=SEU-PROJECT-ID
```

Isso sobrescreve o arquivo `lib/firebase_options.dart` com os dados corretos.

---

## Instalação e Execução

```bash
# 1. Navegar para a pasta do projeto
cd C:\cuidar_plus

# 2. Instalar dependências
flutter pub get

# 3. Executar no Android
flutter run -d android

# 4. Executar no iOS (somente no macOS)
flutter run -d ios

# 5. Executar na web
flutter run -d chrome

# 6. Build para produção web
flutter build web
```

---

## Funcionalidades do MVP

| # | Funcionalidade | Status |
|---|---------------|--------|
| 1 | Login por telefone (OTP SMS) | ✅ |
| 2 | Cadastro de perfil (idoso/familiar/cuidador) | ✅ |
| 3 | Cadastro de medicações | ✅ |
| 4 | Alertas automáticos configuráveis | ✅ |
| 5 | Botão "TOMEI" | ✅ |
| 6 | Botão "AJUDA" de emergência | ✅ |
| 7 | QR Code médico | ✅ |
| 8 | Painel familiar com adesão | ✅ |
| 9 | Relatórios de 7 dias | ✅ |
| 10 | OCR de receita médica | ✅ |
| 11 | Notificações push | ✅ |

---

## Regras Firestore (Segurança)

Cole no Firebase Console → Firestore → Regras:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /elderly/{doc} {
      allow read, write: if request.auth != null;
    }
    match /medications/{doc} {
      allow read, write: if request.auth != null;
    }
    match /medication_logs/{doc} {
      allow read, write: if request.auth != null;
    }
    match /alerts/{doc} {
      allow read, write: if request.auth != null;
    }
    match /qr_profiles/{doc} {
      allow read: if true; // Público para leitura via QR Code
      allow write: if request.auth != null;
    }
  }
}
```

---

## Design

- **Tema**: Verde (`#2E7D32`) — acolhedor e relacionado à saúde
- **Fonte**: 18–28px em todos os textos principais
- **Botões**: Altura mínima 60px
- **Contraste**: Alto contraste em todos os elementos
- **Botão AJUDA**: Vermelho, sempre visível, 1 toque

---

## Próximas Fases

**FASE 2:**
- Painel web completo
- Relatórios avançados com gráficos
- Melhoria no OCR

**FASE 3:**
- Integração WhatsApp
- Integração farmácias
- IA para detecção de padrões
- Planos de assinatura

---

Desenvolvido com Flutter + Firebase | Cuidar+ 2026
