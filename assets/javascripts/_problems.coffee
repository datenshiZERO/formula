window.Problems = [
  {
    title: "Formula",
    id: "atrest",
    description: "Welcome to **Formula**.\n\nThink of it as a racing game where you have to drive through targets along a track.\n",
    board: {
      timePixelRatio: 0.01
    },
    targets:
      1: 1,
    obstacles: []
  },
  {
    title: "Still at Rest",
    id: "stillatrest",
    description: "Testing Markdown  \n_testing_"
    board: {},
    targets:
      10: 100,
      50: 100,
      100: 100,
      300: 100
    obstacles:
      200:
        type: "lt"
        value: -1
  }
  {
    title: "Moving",
    id: "moving",
    description: "Testing Markdown\ntesting"
  }
]
