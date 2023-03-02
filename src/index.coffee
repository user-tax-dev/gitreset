#!/usr/bin/env coffee

> simple-git > simpleGit
  fs:@ > existsSync
  path > dirname join
  chalk
  debug

{gray, greenBright, redBright} = chalk

debug.useColors = => false

debug.formatArgs = (args)=>
  li = args[0]
  cmd = args.pop()
  if cmd != 'git'
    args[1] = ''
    args[0] = ''
  else
    args[0] = gray('❯ ') +  greenBright('%s '+ li[9..-4].replaceAll("', '",' '))
    args[1] = cmd
  return

debug.enable('simple-git')

GIT_DIR = process.cwd()
MSG = '♨'

do =>
  + dir
  loop
    if existsSync join GIT_DIR,'.git'
      break
    dir = dirname GIT_DIR
    if GIT_DIR == dir
      process.exit()
    GIT_DIR = dir
  return

git = simpleGit {
   baseDir: GIT_DIR,
   binary: 'git',
   maxConcurrentProcesses: 6,
   trimmed: false,
}

commit = (msg)=>
  git.add('.').commit(msg or MSG)


do =>
  await commit()
  await git.pull()

  {conflicted} = await git.status()
  if conflicted.length
    console.log redBright ' Please merge conflicted'
    return
  await git.push()

  {all} = await git.log()

  + HASH

  for {hash,message} from all
    if ['♨','.'].includes(message) or message.startsWith 'Merge branch '
      continue
    HASH = hash
    break

  if not HASH
    return

  await git.reset('soft', [HASH])
  await commit process.argv[2..].join(' ')
  await git.pull()
  await git.push()
  #['-f']
  return
