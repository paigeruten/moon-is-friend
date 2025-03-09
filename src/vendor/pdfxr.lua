
local int_to_waves = {
    playdate.sound.kWaveSine     ,
    playdate.sound.kWaveSquare   ,
    playdate.sound.kWaveSawtooth ,
    playdate.sound.kWaveTriangle ,
    playdate.sound.kWaveNoise    ,
    playdate.sound.kWavePOPhase  ,
    playdate.sound.kWavePODigital,
    playdate.sound.kWavePOVosim  ,
}

local int_to_lfo_type = {
    playdate.sound.kLFOSquare,        
    playdate.sound.kLFOSawtoothUp,    
    playdate.sound.kLFOSawtoothDown,  
    playdate.sound.kLFOTriangle,      
    playdate.sound.kLFOSine,          
    playdate.sound.kLFOSampleAndHold, 
}

pdfxr = {}

pdfxr.synth = {}

pdfxr.synth.new = function(filename)
    if not playdate.file.exists(filename) then
        print("pdfxr: No file found at "..filename..". Unable to create new synth.")
        return nil
    end
    local data = json.decodeFile(filename)

    --[[
    duration
    wave
    attack
    decay 
    sustain 
    release 
    curvature
    amp_mod
    freq_mod
    ]]--

    local synth = playdate.sound.synth.new()
    synth:setWaveform(int_to_waves[data.wave])
    synth:setADSR(data.attack, data.decay, data.sustain, data.release, data.curvature)

    local function make_lfo(data)
        if data.enabled then
            --[[
            enabled
            type
            arpeggio
            arpeggio_enabled
            center
            depth
            rate
            phase -- never will be used
            start_phase
            delay_start
            delay_fade 
            ]]--
            local lfo = playdate.sound.lfo.new(int_to_lfo_type[data.type])
            lfo:setCenter(data.center)
            lfo:setDepth(data.depth)
            lfo:setRate(data.rate)
            lfo:setStartPhase(data.start_phase)
            if data.arpeggio_enabled then                
                if data.arpeggio[5] > 0 then
                    lfo:setArpeggio(math.floor(data.arpeggio[1]),
                    math.floor(data.arpeggio[2]),
                    math.floor(data.arpeggio[3]),
                    math.floor(data.arpeggio[4]),
                    math.floor(data.arpeggio[5]))
                elseif data.arpeggio[4] > 0 then
                    lfo:setArpeggio(math.floor(data.arpeggio[1]),
                    math.floor(data.arpeggio[2]),
                    math.floor(data.arpeggio[3]),
                    math.floor(data.arpeggio[4]))
                elseif data.arpeggio[3] > 0 then
                    lfo:setArpeggio(math.floor(data.arpeggio[1]),
                    math.floor(data.arpeggio[2]),
                    math.floor(data.arpeggio[3]))
                elseif data.arpeggio[2] > 0 then
                    lfo:setArpeggio(math.floor(data.arpeggio[1]),
                    math.floor(data.arpeggio[2]))
                elseif data.arpeggio[1] > 0 then
                    lfo:setArpeggio(math.floor(data.arpeggio[1]))
                else
                    lfo:setArpeggio(0)
                end
            end
            if data.delay_start and data.delay_fade then
                lfo:setDelay(data.delay_start,data.delay_fade)
            end
            lfo:setRetrigger(true)
            return lfo
        else return nil end
    end

    local lfo = make_lfo(data.amp_mod)
    if lfo then 
        synth:setAmplitudeMod(lfo)
    end
    lfo = make_lfo(data.freq_mod)
    if lfo then 
        synth:setFrequencyMod(lfo)
    end

    local rv = {}    
    rv.synth = synth
    rv.duration = data.duration + data.attack + data.decay
    if data.note then
        rv.note = data.note
    end
    -- plays the synth for the duration set in the data at the given midi note or the pitch set in the data if nil
    rv.play = function(self, midi_note, volume)
        if not volume then volume = self.volume end
        if not midi_note then 
            if self.note then
                if self.lock_note_to_integer then
                    midi_note = math.floor(self.note)
                else
                    midi_note = self.note
                end
            else
                midi_note = 60
            end
        end
        self.synth:playMIDINote(midi_note, volume, self.duration)
    end
    -- starts playing the synth until you call stop
    rv.start = function(self, midi_note, volume)
        if not volume then volume = self.volume end
        if not midi_note then 
            if self.note then
                if self.lock_note_to_integer then
                    midi_note = math.floor(self.note)
                else
                    midi_note = self.note
                end
            else
                midi_note = 60
            end
        end
        local pitch = (2^((midi_note-69)/12))*440
        self.synth:playNote(pitch, volume)
    end
    -- stops the synth (and plays the release)
    rv.stop = function(self)
        self.synth:noteOff()
    end
    return rv
end