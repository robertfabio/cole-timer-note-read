# Cole App Flutter

Uma aplicação de timer para estudos com foco em produtividade usando a técnica Pomodoro.

## Recursos

- Timer com técnica Pomodoro (25min de foco, 5min de pausa curta, 15min de pausa longa)
- Modo de cronômetro para sessões livres
- Estatísticas de estudo (diárias, semanais e mensais)
- Rastreamento de sequência de estudos (streak)
- Sistema de notas para organizar atividades
- Modos claro e escuro

## Alterações Implementadas

- Interface mais atraente com cores aconchegantes e fundo branco
- Timer em tela cheia redesenhado para maximizar espaço
- Tela inicial melhorada com mais informações e funcionalidades
- Sistema de constância de estudos para acompanhar seu progresso
- Melhoria na exibição e organização de notas
- Configurações para personalizar o aplicativo

## Como configurar o ícone do aplicativo

Para definir o gato com relógio como ícone do aplicativo:

1. Salve a imagem do gato fornecida (2.png) em `assets/icons/app_icon.png`
2. Execute o comando:

```
flutter pub run flutter_launcher_icons
```

Este comando irá gerar os ícones para Android, iOS e outras plataformas conforme configurado no arquivo `flutter_launcher_icons.yaml`.

## Desenvolvido com

- Flutter
- Dart
- Provider para gerenciamento de estado
- Flutter Material 3 para design
