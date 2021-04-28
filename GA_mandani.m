clear all;
clc;
tamanho_cromossomo=42;
tamanho_popu=50;
elite=4; %numero de individuos da elite que ir„o passar
geracoes=35;

cromo1 = [-30 -30 -16 0 0 0 16 30 30 -0.3 -0.3 -0.247 0 0 0 0.247 0.3 0.3 1 2 5 3 3 5 5 4 5 -1.23 -1.23 -0.9762 -0.4553 -0.6225 -0.6225 0 0 0 0.6225 0.599 0.773 1 1 1]

pop_i=gerar_pop(tamanho_popu,tamanho_cromossomo);
pop_i(1,:)=cromo1;

[pop_rankeado, elites, notas]=ranked(pop_i,tamanho_popu, tamanho_cromossomo, elite, 1);


gera=1
rank1=pop_rankeado;

for i=1:geracoes
    gera=i+1
    pop_i=gerar_nova_pop(tamanho_popu, tamanho_cromossomo, elites, pop_rankeado,notas, pop_i);
    [pop_rankeado, elites, notas]=ranked(pop_i, tamanho_popu, tamanho_cromossomo, elite, gera);
end

function novo_cromo=criar_cromossomo()
    %Criar erro de -30 a 30
    for i=1:9
        tempo1(i)=(60*rand)-30;
    end
    tempo1=sort(tempo1);
    %Criar var_erro de -0.3 a 0.3
    for i=1:9
        tempo2(i)=(0.6*rand)-0.3;
        tempo2=sort(tempo2);
    end
    tempo2=sort(tempo2);
    %0.1's entre 10^-1 e 10^-3 e os maiores entre 1 e 10
    for i=1:15
        tempo3(i)=(2.4*rand)-1.2;
    end
    tempo3=sort(tempo3);
    regra=[1 2 5 3 3 5 5 4 5];
    %finalesco=[0.01 3 0.01 3.5 0.1 5];
    novo_cromo=[tempo1 tempo2 regra tempo3];
end

function pop=gerar_pop(tamanho_pop, tamanho_individuo)
    for i=1:tamanho_pop
        pop(i,:)=criar_cromossomo();
    end
end

function [pop_rankeado, elites, notas]=ranked(populacao,tamanho_pop, tamanho_individuo, qntd_elite, gera_atual)
    for i=1:tamanho_pop
        itera=[gera_atual i]
        %Para cada individuo gera um fis, simula, da a nota
        man33(populacao(i,:)); 
        sim('Simulacao_Exemplo_04_Fuzzy_v2');
        teste_divergencia=sort(Niveis(:,4));
        tamanho=length(teste_divergencia);
        if teste_divergencia(tamanho)>=26
            notas(i)=100;
        else
            notas(i)=goodhart(Sinal_Controle_U(:,2),15,Niveis(:,4));
        end
    end
    temp=[populacao notas']; %concatena a populaÁ„o c a nota de cada individuo
    temp_sorted=sortrows(temp,tamanho_individuo+1,{'ascend'}); %Rankeia de maneira crescente (menor nota em cima pois È melhor)
    elites=temp_sorted(1:qntd_elite,1:tamanho_individuo); %Separa os da elite
    pop_rankeado=temp_sorted; %vetor populaÁ„o+nota rankeado
    notas=pop_rankeado(:,tamanho_individuo+1); %vetor coluna sÛ de notas
end

function posicao=sorteio(notas, tamanho_pop)
    nova_nota=1./notas;
    soma_notas=0;
    for i=1:tamanho_pop
        soma_notas=notas(i)+soma_notas;
    end    
    sorteado=soma_notas*rand;    
    pos=0;
    i=0;
    while pos<sorteado
        i=i+1;
        pos=notas(i)+pos;
        posicao=i;
    end
end


function filho=gerar_novo_individuo(pai1, pai2, pai3, tamanho_individuo)
    %filho=[pai1(1,1:15) pai2(1,16:24) pai3(1,25:45)];
    filho=[pai1(1,1:3) pai2(1,4:6) pai3(1,7:9) pai1(1,10:12) pai2(1,13:15) pai3(1,16:18) pai1(1,19:27) pai1(1,28:30) pai2(1,31:33) pai3(1,34:36) pai1(1,37:39) pai2(1,40:42)];
    chance_wolwerine=rand;
    if chance_wolwerine<=0.05
        pos_mut=ceil(48*rand); %arredonda pra cima pra nunca ser zero, sÛ pos final do cromossomo
        if (pos_mut>=1)&&(pos_mut<=9)
            filho(pos_mut)=(60*rand)-30;
        elseif (pos_mut>=10)&&(pos_mut<=18)
            filho(pos_mut)=(0.6*rand)-0.3;
        elseif (pos_mut>=28)&&(pos_mut<=42)
            filho(pos_mut)=(2*rand)-1;
        end
    end
    tempo1=sort(filho(1:9));
    tempo2=sort(filho(10:18));
    tempo3=sort(filho(28:42));
    filho=[tempo1 tempo2 filho(19:27) tempo3];
end


function nova_populacao=gerar_nova_pop(tamanho_pop, tamanho_individuo, elites, ordenado, notas, populacao_pai)
    nova_populacao=[];
    for i=1:tamanho_pop-6
        pos1=sorteio(notas,tamanho_pop);
        pos2=sorteio(notas,tamanho_pop);
        pos3=sorteio(notas,tamanho_pop);
        nova_populacao(i,:)=gerar_novo_individuo(populacao_pai(pos1,:),populacao_pai(pos2,:),populacao_pai(pos3,:),tamanho_individuo);
        nova_populacao(i+1,:)=gerar_novo_individuo(populacao_pai(pos3,:),populacao_pai(pos1,:),populacao_pai(pos2,:),tamanho_individuo);
        nova_populacao(i+2,:)=gerar_novo_individuo(populacao_pai(pos2,:),populacao_pai(pos3,:),populacao_pai(pos1,:),tamanho_individuo);
        i=i+2;
    end
    if length(nova_populacao)>=tamanho_pop-4
        nova_populacao=nova_populacao(1:tamanho_pop-4,:);
    end
    nova_populacao=[nova_populacao; elites];
end

%FunÁ„o Jaci
function man33(cromo)

%cromossomo de teste:
%cromo = [-30 -30 -16 0 0 0 16 30 30 -0.3 -0.3 -0.247 0 0 0 0.247 0.3 0.3 1 2 5 3 3 5 5 4 5 -1.23 -1.23 -0.9762 -0.4553 -0.6225 -0.6225 0 0 0 0.6225 0.599 0.773 1 1 1]
%saidaf = 0;

%

b = newfis('tipper');  %cria um novo fis
%b = mamfis;     usa para o modelo mamdani

%b.type = 'sugeno';      %mudo de mamdami para sugeno

b = addvar(b,'input','erro',[cromo(1) cromo(9)]); % crio a entrada do erro
% A seguir s√£o especificados os paramentros das fun√ß√µes do erro
b = addmf(b,'input',1,'EN','trimf',[cromo(1) cromo(2) cromo(4)]);  
b = addmf(b,'input',1,'NZ','trimf',[cromo(3) cromo(5) cromo(7)]);
b = addmf(b,'input',1,'EP','trimf',[cromo(6) cromo(8) cromo(9)]);


b = addvar(b,'input','var_erro',[cromo(11) cromo(19)]); % crio a entrada da varia√ß√£o do erro
% A seguir s√£o especificados os paramentros das fun√ß√µes da varia√ß√£o do erro
b = addmf(b,'input',2,'VN','trimf',[cromo(10) cromo(11) cromo(13)]);
b = addmf(b,'input',2,'VZ','trimf',[cromo(12) cromo(14) cromo(16)]);
b = addmf(b,'input',2,'VP','trimf',[cromo(15) cromo(17) cromo(18)]);

b = addvar(b,'output','saidaFuzzy',[-1 1]);  % crio a saida do controle
b = addmf(b,'output',1,'DUNG','trimf',[cromo(28) cromo(29) cromo(31)]); %1
b = addmf(b,'output',1,'DUNP','trimf',[cromo(30) cromo(32) cromo(34)]); %2
b = addmf(b,'output',1,'DUZ','trimf',[cromo(33) cromo(35) cromo(37)]);  %3
b = addmf(b,'output',1,'DUPP','trimf',[cromo(36) cromo(38) cromo(40)]);  %4
b = addmf(b,'output',1,'DUPG','trimf',[cromo(39) cromo(41) cromo(42)]);  %5
%especifico as regras;
%primeira coluna √© referente as fun√ß√µes do erro
%segunda coluna referente as fun√ß√µes da varia√ß√£o do erro
%a terceira coluna √© referente a saida do controle
%a quarta e quinta n√£o varia, sempre √© 1 e 1
ruleList = [1 1 cromo(19) 1 1;
            1 2 cromo(20) 1 1;
            1 3 cromo(21) 1 1;
            2 1 cromo(22) 1 1;
            2 2 cromo(23) 1 1;
            2 3 cromo(24) 1 1;
            3 1 cromo(25) 1 1
            3 2 cromo(26) 1 1;
            3 3 cromo(27) 1 1];
           
                
            
b = addrule(b,ruleList);

%sug_fis = mam2sug(b)  %transforma de mamdani para sugeno

writefis(b,'my_file1');   %crio o aquivo .fis


end

%FunÁ„o Rafael
function IG = goodhart(u,r,y)
    alfa1=0.2;
    alfa2=0.3;
    alfa3=0.5;
    
    %R=setpoint
    %U=sinal de controle Sinal_Controle_U(:,2)
    %Y=saÌda - Niveis(:,4)

    L1=length(u);
    L2=length(y);

    E1 = sum(u)/L1;
    E2 = sum((u-E1))^2/L1;
    E3 = sum((r-y))^2/L2;

    IG = (alfa1*E1 + alfa2*E2 + alfa3*E3)/1000; 
end
